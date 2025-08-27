-- PrefabSpawner.server.lua
-- Auto-spawns models from ReplicatedStorage/Models into Workspace/World based on name prefixes.
-- Supports per-model Attributes: TargetFolder (string), Count (int), X/Y/Z (numbers), Yaw (deg), MinScale, MaxScale.

local RS        = game:GetService("ReplicatedStorage")
local RunService= game:GetService("RunService")

local Config    = require(script.Parent["_Config.module"])
local Rules     = require(script.Parent["_PrefabRules.module"])
local Spawner   = require(script.Parent["_Spawner.util"])

local Models = RS:FindFirstChild("Models")
if not Models then
    warn("[PrefabSpawner] No ReplicatedStorage.Models folder found. Skipping.")
    return
end

-- Prepare World and Spawned container (so we never overwrite your hand-placed assets)
local World = workspace:FindFirstChild("World") or Instance.new("Folder")
World.Name = "World"; World.Parent = workspace
local Spawned = World:FindFirstChild("Spawned") or Instance.new("Folder")
Spawned.Name = "Spawned"; Spawned.Parent = World

-- If baking in Edit mode, clear Spawned once so you can re-generate and then Save the map
if Config.BAKE_MODE and not RunService:IsRunning() then
    Spawned:ClearAllChildren()
end

local function getRuleForName(name: string)
    local prefix = name:match("^([A-Za-z]+)[_%s]") or name:match("^([A-Za-z]+)")
    if prefix and Rules[prefix] then
        return Rules[prefix], prefix
    end
    return Rules.__default, "__default"
end

local function inAvoidBands(pos: Vector3)
    for _,band in ipairs(Config.AVOID_BANDS or {}) do
        if band.axis == "Z" then
            if math.abs(pos.Z - (band.center or 0)) <= (band.margin or 20) then return true end
        elseif band.axis == "X" then
            if math.abs(pos.X - (band.center or 0)) <= (band.margin or 20) then return true end
        end
    end
    return false
end

local function randBetween(a: number, b: number) return a + math.random() * (b - a) end

local function randomPos(area)
    local x = randBetween(area.min.X, area.max.X)
    local z = randBetween(area.min.Z, area.max.Z)
    return Vector3.new(x, 0, z)
end

-- Ensure a subfolder under Spawned for each target folder (e.g., Castle, Nature, etc.)
local function ensureSpawnBucket(name: string)
    local tgt = Spawned:FindFirstChild(name)
    if not tgt then
        tgt = Instance.new("Folder"); tgt.Name = name; tgt.Parent = Spawned
    end
    return tgt
end

-- Resolve final placement settings for a given prefab (model) and its rule
local function resolvePlacement(prefab: Instance, rule)
    -- Attributes override defaults
    local count   = tonumber(prefab:GetAttribute("Count")) or rule.count or 1
    local tgtFol  = prefab:GetAttribute("TargetFolder") or rule.folder or "Nature"
    local area    = rule.area or Config.SCATTER_AREA
    local minS    = tonumber(prefab:GetAttribute("MinScale")) or rule.minScale or 1.0
    local maxS    = tonumber(prefab:GetAttribute("MaxScale")) or rule.maxScale or 1.0
    local yawOnly = (prefab:GetAttribute("YawOnly") ~= nil) and (prefab:GetAttribute("YawOnly") == true) or (rule.yawOnly ~= false)

    -- Fixed placement overrides (Attributes > rule.fixedPos)
    local attrHasFixed = (prefab:GetAttribute("X") ~= nil) or (prefab:GetAttribute("Y") ~= nil) or (prefab:GetAttribute("Z") ~= nil)
    local fx  = tonumber(prefab:GetAttribute("X"))
    local fy  = tonumber(prefab:GetAttribute("Y"))
    local fz  = tonumber(prefab:GetAttribute("Z"))
    local fay = tonumber(prefab:GetAttribute("Yaw")) -- degrees

    local fixedPos = nil
    if attrHasFixed then
        fixedPos = Vector3.new(fx or 0, fy or 0, fz or 0)
    elseif rule.fixedPos then
        fixedPos = rule.fixedPos
    end

    local fixedYaw = nil
    if fay ~= nil then
        fixedYaw = fay
    elseif rule.fixedYaw ~= nil then
        fixedYaw = rule.fixedYaw
    end

    return {
        count        = count,
        targetFolder = tgtFol,
        area         = area,
        minScale     = minS,
        maxScale     = maxS,
        yawOnly      = yawOnly,
        fixed        = fixedPos,   -- Vector3 or nil
        fixedYaw     = fixedYaw,   -- degrees or nil
    }
end

-- Main pass: for each Model under ReplicatedStorage/Models, spawn according to its rule
for _,prefab in ipairs(Models:GetChildren()) do
    if not prefab:IsA("Model") then continue end
    local rule = getRuleForName(prefab.Name)
    local settings = resolvePlacement(prefab, rule)

    local bucket = ensureSpawnBucket(settings.targetFolder)

    for i = 1, settings.count do
        local pos
        if settings.fixed then
            pos = settings.fixed
        else
            pos = randomPos(settings.area or Config.SCATTER_AREA)
            -- obey avoid bands (attempt up to 8 tries)
            local tries = 0
            while inAvoidBands(pos) and tries < 8 do
                pos = randomPos(settings.area or Config.SCATTER_AREA)
                tries += 1
            end
        end

        local yawRad
        if settings.fixedYaw ~= nil then
            yawRad = math.rad(settings.fixedYaw)
        elseif settings.yawOnly ~= false then
            yawRad = math.rad(math.random(0,359))
        else
            yawRad = 0
        end

        local cf = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(0, yawRad, 0)
        local clone = Spawner.CloneAt(prefab, bucket, cf, settings.minScale, settings.maxScale)
        if clone then
            clone.Name = string.format("%s_%d", prefab.Name, i)
        end
    end
end

print("[PrefabSpawner] Completed spawning from ReplicatedStorage.Models into World/Spawned.")

