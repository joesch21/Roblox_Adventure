local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config  = require(script.Parent["_Config.module"])
local Rules   = require(script.Parent["_PrefabRules.module"])
local Spawner = require(script.Parent["_Spawner.util"])

local Models = RS:FindFirstChild("Models")
if not Models then
  warn("[PrefabSpawner] ReplicatedStorage.Models not found. Skipping.")
  return
end

local World = workspace:FindFirstChild("World") or Instance.new("Folder")
World.Name = "World"; World.Parent = workspace
local Spawned = World:FindFirstChild("Spawned") or Instance.new("Folder")
Spawned.Name = "Spawned"; Spawned.Parent = World

if Config.BAKE_MODE and not RunService:IsRunning() then
  Spawned:ClearAllChildren()
end

local function getRuleForName(name: string)
  local prefix = name:match("^([A-Za-z]+)[_%s]") or name:match("^([A-Za-z]+)")
  return (prefix and Rules[prefix]) and Rules[prefix] or Rules.__default, prefix or "__default"
end

local function inAvoidBands(pos: Vector3)
  for _,b in ipairs(Config.AVOID_BANDS or {}) do
    if b.axis == "Z" then
      if math.abs(pos.Z - (b.center or 0)) <= (b.margin or 20) then return true end
    elseif b.axis == "X" then
      if math.abs(pos.X - (b.center or 0)) <= (b.margin or 20) then return true end
    end
  end
  return false
end

local function randBetween(a,b) return a + math.random()*(b-a) end
local function randomPos(area)
  return Vector3.new(randBetween(area.min.X, area.max.X), 0, randBetween(area.min.Z, area.max.Z))
end

local function ensureBucket(name: string)
  local f = Spawned:FindFirstChild(name)
  if not f then f = Instance.new("Folder"); f.Name = name; f.Parent = Spawned end
  return f
end

local function resolvePlacement(prefab: Instance, rule)
  local count   = tonumber(prefab:GetAttribute("Count")) or rule.count or 1
  local tgt     = prefab:GetAttribute("TargetFolder") or rule.folder or "Nature"
  local area    = rule.area or Config.SCATTER_AREA
  local minS    = tonumber(prefab:GetAttribute("MinScale")) or rule.minScale or 1.0
  local maxS    = tonumber(prefab:GetAttribute("MaxScale")) or rule.maxScale or 1.0
  local yawOnly = (prefab:GetAttribute("YawOnly") ~= nil) and (prefab:GetAttribute("YawOnly") == true) or (rule.yawOnly ~= false)

  local hasFixed = (prefab:GetAttribute("X") ~= nil) or (prefab:GetAttribute("Y") ~= nil) or (prefab:GetAttribute("Z") ~= nil)
  local fx, fy, fz = tonumber(prefab:GetAttribute("X")), tonumber(prefab:GetAttribute("Y")), tonumber(prefab:GetAttribute("Z"))
  local ay = tonumber(prefab:GetAttribute("Yaw"))

  local fixedPos = hasFixed and Vector3.new(fx or 0, fy or 0, fz or 0) or rule.fixedPos
  local fixedYaw = (ay ~= nil) and ay or rule.fixedYaw

  return {
    count=count, targetFolder=tgt, area=area,
    minScale=minS, maxScale=maxS, yawOnly=yawOnly,
    fixed=fixedPos, fixedYaw=fixedYaw,
  }
end

for _,prefab in ipairs(Models:GetChildren()) do
  if not prefab:IsA("Model") then continue end
  local rule, prefix = getRuleForName(prefab.Name)
  local settings = resolvePlacement(prefab, rule)

  local bucket = ensureBucket(settings.targetFolder)
  for i=1, settings.count do
    local pos = settings.fixed or (function()
      local p, tries = randomPos(settings.area), 0
      while inAvoidBands(p) and tries < 8 do p, tries = randomPos(settings.area), tries+1 end
      return p
    end)()

    local yawRad
    if settings.fixedYaw ~= nil then
      yawRad = math.rad(settings.fixedYaw)
    elseif settings.yawOnly ~= false then
      yawRad = math.rad(math.random(0,359))
    else
      yawRad = 0
    end

    local cf = CFrame.new(pos) * CFrame.Angles(0, yawRad, 0)
    local clone = Spawner.CloneAt(prefab, bucket, cf, settings.minScale, settings.maxScale)
    if clone then clone.Name = string.format("%s_%d", prefab.Name, i) end
  end
end

print("[PrefabSpawner] Spawn complete into World/Spawned.")

