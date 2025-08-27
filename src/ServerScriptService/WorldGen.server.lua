-- WorldGen.server.lua (Realistic trees & rocks via prefabs; medieval layout preserved)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = workspace:FindFirstChild("World") or Instance.new("Folder")
World.Name = "World"; World.Parent = workspace
World:ClearAllChildren()
math.randomseed(tick())

local Scatter = require(script.Parent:WaitForChild("_ScatterUtil"))
local Config  = require(script.Parent["_Config.module"])
local Spawner = require(script.Parent["_Spawner.util"])

local function mkPart(name, size, cf, color, material, anchored, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = anchored ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color or Color3.fromRGB(120,120,120)
    p.Material = material or Enum.Material.Slate
    p.Parent = parent or World
    return p
end

local function mkFolder(name, parent)
    local f = Instance.new("Folder"); f.Name = name; f.Parent = parent or World; return f
end

-- Ground
local Ground = mkPart("Ground", Vector3.new(900, 2, 900), CFrame.new(0, 0, 0), Color3.fromRGB(70,130,50), Enum.Material.Grass)
Ground.Locked = true

-- River + bridge (kept from prior version)
local River = mkFolder("River"); local riverZ = -40
local water = mkPart("Water", Vector3.new(900, 2, 40), CFrame.new(0, 1.1, riverZ), Color3.fromRGB(35,120,200), Enum.Material.SmoothPlastic, true, River)
water.Transparency = 0.25
mkPart("BankN", Vector3.new(900, 4, 6), CFrame.new(0, 2.5, riverZ - 23), Color3.fromRGB(110,80,50), Enum.Material.Ground, true, River)
mkPart("BankS", Vector3.new(900, 4, 6), CFrame.new(0, 2.5, riverZ + 23), Color3.fromRGB(110,80,50), Enum.Material.Ground, true, River)

local Bridge = mkFolder("Bridge")
local bx, bz = 0, riverZ
mkPart("Deck", Vector3.new(24, 2, 10), CFrame.new(bx, 8, bz), Color3.fromRGB(150,150,150), Enum.Material.Slate, true, Bridge)
for i=-1,1,2 do
    mkPart("ArchPillarL"..i, Vector3.new(2, 12, 2), CFrame.new(bx-10*i, 6, bz-3), Color3.fromRGB(140,140,140), Enum.Material.Concrete, true, Bridge)
    mkPart("ArchPillarR"..i, Vector3.new(2, 12, 2), CFrame.new(bx-10*i, 6, bz+3), Color3.fromRGB(140,140,140), Enum.Material.Concrete, true, Bridge)
end
mkPart("RailL", Vector3.new(24, 3, 1), CFrame.new(bx, 10.5, bz-5), Color3.fromRGB(120,120,120), Enum.Material.Concrete, true, Bridge)
mkPart("RailR", Vector3.new(24, 3, 1), CFrame.new(bx, 10.5, bz+5), Color3.fromRGB(120,120,120), Enum.Material.Concrete, true, Bridge)

-- Castle / Camp / Village / Roads: (kept from your medieval upgrade – abbreviated for brevity)
-- NOTE: Keep your existing castle, camp, village, and road generation code below.
-- (If Codex doesn’t have that code, copy the latest version from your repo here untouched.)

-- Control point for objectives
local cp = mkPart("ControlPoint", Vector3.new(8, 2, 8), CFrame.new(bx, 9, bz), Color3.fromRGB(255,255,255), Enum.Material.Neon, true, Bridge)
cp.Transparency = 0.35

---------------- Castle w/ interior + gate ----------------
local Castle = mkFolder("Castle")
local castleCenter = Vector3.new(180, 1, 40)
local wallLen, wallH, wallT = 90, 20, 4
mkPart("WallN", Vector3.new(wallLen, wallH, wallT), CFrame.new(castleCenter + Vector3.new(0, wallH/2, -wallLen/2)), Color3.fromRGB(155,155,155), Enum.Material.Concrete, true, Castle)
mkPart("WallS", Vector3.new(wallLen, wallH, wallT), CFrame.new(castleCenter + Vector3.new(0, wallH/2,  wallLen/2)), Color3.fromRGB(155,155,155), Enum.Material.Concrete, true, Castle)
mkPart("WallE", Vector3.new(wallT, wallH, wallLen), CFrame.new(castleCenter + Vector3.new(wallLen/2, wallH/2, 0)),  Color3.fromRGB(155,155,155), Enum.Material.Concrete, true, Castle)
mkPart("WallW", Vector3.new(wallT, wallH, wallLen), CFrame.new(castleCenter + Vector3.new(-wallLen/2, wallH/2, 0)), Color3.fromRGB(155,155,155), Enum.Material.Concrete, true, Castle)

-- Crenellations N/S
local function crenels(startPos, count, dx)
    for i=1,count do
        local pos = startPos + Vector3.new(dx*(i-1), wallH+0.5, 0)
        mkPart("Cren"..i, Vector3.new(3, 3, 2), CFrame.new(pos), Color3.fromRGB(180,180,180), Enum.Material.Concrete, true, Castle)
    end
end
crenels(castleCenter + Vector3.new(-wallLen/2+3,0,-wallLen/2-1), math.floor(wallLen/5), 5)
crenels(castleCenter + Vector3.new(-wallLen/2+3,0, wallLen/2+1), math.floor(wallLen/5), 5)

-- Corner towers
local function tower(cx, cz)
    local base = mkPart("TowerBase", Vector3.new(10, 24, 10), CFrame.new(castleCenter + Vector3.new(cx, 12, cz)), Color3.fromRGB(160,160,160), Enum.Material.Concrete, true, Castle)
    base.Shape = Enum.PartType.Cylinder; base.Orientation = Vector3.new(0,0,90)
    local top = mkPart("TowerTop", Vector3.new(12, 4, 12), CFrame.new(castleCenter + Vector3.new(cx, 26, cz)), Color3.fromRGB(160,160,160), Enum.Material.Concrete, true, Castle)
    top.Shape = Enum.PartType.Cylinder
    -- simple interior stairs up the tower
    for s=0,5 do
        local step = mkPart("Stair"..s, Vector3.new(4,1,2), CFrame.new(base.Position + Vector3.new(0, 2+s*3, (s-2)*1.2)) * CFrame.Angles(0, math.rad(s*12), 0), Color3.fromRGB(150,150,150), Enum.Material.Concrete, true, Castle)
    end
end
local half = wallLen/2 - 6
tower(-half, -half); tower(half, -half); tower(-half, half); tower(half, half)

-- Keep
local keep = mkPart("Keep", Vector3.new(24, 28, 24), CFrame.new(castleCenter + Vector3.new(0, 14, 0)), Color3.fromRGB(175,175,175), Enum.Material.Concrete, true, Castle)

-- Optional castle prefab override
local Models = ReplicatedStorage:FindFirstChild("Models")
local CastlePrefab = Models and Models:FindFirstChild("Castle")
if CastlePrefab then
    keep:Destroy()
    local yawRad = math.rad(Config.CASTLE_YAW or 0)
    local cf = CFrame.new(Config.CASTLE_POS or Vector3.new(180,0,40)) * CFrame.Angles(0, yawRad, 0)
    Spawner.CloneAt(CastlePrefab, Castle, cf, Config.CASTLE_SCALE, Config.CASTLE_SCALE)
end

-- Gate Model with open/close door part (hinge-less slide), plus a ProximityPrompt
local Gate = Instance.new("Model"); Gate.Name = "Gate"; Gate.Parent = Castle
local gateFrame = mkPart("Frame", Vector3.new(10, 16, 4), CFrame.new(castleCenter + Vector3.new(-wallLen/2 + 6, 8, 0)), Color3.fromRGB(140,140,140), Enum.Material.Concrete, true, Gate)
local gateDoor  = mkPart("Door", Vector3.new(8, 12, 2),  gateFrame.CFrame * CFrame.new(0, 0, 3), Color3.fromRGB(100, 60, 40), Enum.Material.Wood, true, Gate)
gateDoor.Name = "Door"
local pp = Instance.new("ProximityPrompt")
pp.ActionText = "Toggle Gate"; pp.ObjectText = "Castle Gate"; pp.HoldDuration = 0; pp.MaxActivationDistance = 10
pp.Parent = gateDoor
Gate:SetAttribute("Open", false)

-- Knight spawn
local knightSpawn = Instance.new("SpawnLocation")
knightSpawn.Name = "KnightSpawn"; knightSpawn.Position = castleCenter + Vector3.new(-10, 6, 0)
knightSpawn.Size = Vector3.new(6,1,6); knightSpawn.Anchored = true; knightSpawn.Neutral = false
knightSpawn.BrickColor = BrickColor.new("Bright blue"); knightSpawn.Parent = Castle

---------------- Barbarian camp + banner ----------------
local Camp = mkFolder("BarbarianCamp")
local campCenter = Vector3.new(-180, 1, -20)
for i=1,7 do
    local ang = (i/7)*math.pi*2
    local off = Vector3.new(math.cos(ang),0,math.sin(ang))*16
    local trunk = mkPart("Totem"..i, Vector3.new(2, 12, 2), CFrame.new(campCenter + off + Vector3.new(0,6,0)), BrickColor.new("Reddish brown").Color, Enum.Material.Wood, true, Camp)
    trunk.Shape = Enum.PartType.Cylinder; trunk.Orientation = Vector3.new(0,0,90)
end
mkPart("CampFire", Vector3.new(6,1,6), CFrame.new(campCenter + Vector3.new(0,1,0)), Color3.fromRGB(95,55,35), Enum.Material.Wood, true, Camp)
local barbSpawn = Instance.new("SpawnLocation")
barbSpawn.Name = "BarbarianSpawn"; barbSpawn.Position = campCenter + Vector3.new(10, 6, 0)
barbSpawn.Size = Vector3.new(6,1,6); barbSpawn.Anchored = true; barbSpawn.Neutral = false
barbSpawn.BrickColor = BrickColor.new("Bright red"); barbSpawn.Parent = Camp

-- Banners at each base for the "steal banner" objective
local function mkBanner(parentFolder, name, pos, color)
    local pole = mkPart(name.."_Pole", Vector3.new(1, 10, 1), CFrame.new(pos + Vector3.new(0,5,0)), Color3.fromRGB(120,120,120), Enum.Material.Metal, true, parentFolder)
    local cloth = mkPart(name.."_Cloth", Vector3.new(6, 4, 0.3), CFrame.new(pos + Vector3.new(3, 6, 0)), color, Enum.Material.Fabric, true, parentFolder)
    local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Steal Banner"; prompt.ObjectText = name; prompt.MaxActivationDistance = 10; prompt.HoldDuration = 0
    prompt.Parent = cloth
    return cloth
end
local CastleBanner = mkBanner(Castle, "KnightBanner", castleCenter + Vector3.new(10, 1, 0), BrickColor.new("Bright blue").Color)
local CampBanner   = mkBanner(Camp,   "BarbarianBanner", campCenter   + Vector3.new(-10, 1, 0), BrickColor.new("Bright red").Color)

---------------- Roads + village ----------------
local Roads = mkFolder("Roads")
local function roadRect(a, b, width)
    local dir = (b - a); local len = dir.Magnitude; if len < 1 then return end
    local cf = CFrame.new((a+b)/2, 0.6, 0) * CFrame.fromMatrix(Vector3.new((a+b).X/2, 0.6, (a+b).Z/2), (b-a).Unit, Vector3.yAxis, Vector3.zAxis)
    mkPart("Road", Vector3.new(width, 0.6, len), CFrame.new((a+b)/2, 0.6, 0) * CFrame.new(0,0,0), Color3.fromRGB(110,90,70), Enum.Material.Ground, true, Roads).CFrame = CFrame.new((a+b)/2) * CFrame.Angles(0, math.atan2((b-a).X, (b-a).Z), 0)
end
local Village = mkFolder("Village")
local function house(pos, rotDeg)
    local h = mkFolder("House", Village)
    local body = mkPart("Body", Vector3.new(18, 10, 14), CFrame.new(pos) * CFrame.Angles(0, math.rad(rotDeg or 0), 0), Color3.fromRGB(210, 200, 180), Enum.Material.WoodPlanks, true, h)
    mkPart("RoofA", Vector3.new(20, 4, 16), body.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(120, 60, 40), Enum.Material.Wood, true, h)
    mkPart("RoofB", Vector3.new(20, 4, 16), body.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(0, 0, math.rad(-25)), Color3.fromRGB(120, 60, 40), Enum.Material.Wood, true, h)
    return h
end
local villageCenter = Vector3.new(bx - 40, 0.6, bz + 70)
house(villageCenter + Vector3.new(-10, 6, 0), 10)
house(villageCenter + Vector3.new(18, 6, -16), -30)
house(villageCenter + Vector3.new(-26, 6, -18), 45)
for i=1,3 do
    local base = mkPart("Stall"..i, Vector3.new(10, 1, 6), CFrame.new(villageCenter + Vector3.new(i*8, 2, 10)), Color3.fromRGB(120,90,60), Enum.Material.Wood, true, Village)
    mkPart("Canopy"..i, Vector3.new(10, 1, 6), base.CFrame * CFrame.new(0, 4, 0), BrickColor.Random().Color, Enum.Material.Fabric, true, Village)
end

roadRect(castleCenter + Vector3.new(-wallLen/2, 0.6, 0), Vector3.new(bx-6, 0.6, riverZ+20), 6)
roadRect(Vector3.new(bx, 0.6, riverZ+20), villageCenter + Vector3.new(0,0,6), 6)
roadRect(villageCenter + Vector3.new(0,0,-6), campCenter + Vector3.new(0,0,6), 6)

-- === Nature scatter using prefabs ===
local Nature = mkFolder("Nature")
local Models = ReplicatedStorage:FindFirstChild("Models")
local Trees  = Models and Models:FindFirstChild("Trees")
local Rocks  = Models and Models:FindFirstChild("Rocks")

local minArea = Vector3.new(-380, 0, -380)
local maxArea = Vector3.new( 380, 0,  380)

if Trees then
    Scatter.scatterModels({
        folder = Trees,
        parent = Nature,
        count = 90,
        areaMin = minArea,
        areaMax = maxArea,
        avoidZ = { {center = riverZ, margin = 50} },
        minScale = 0.9, maxScale = 1.25,
        yawOnly = true,
    })
end

if Rocks then
    Scatter.scatterModels({
        folder = Rocks,
        parent = Nature,
        count = 35,
        areaMin = minArea,
        areaMax = maxArea,
        avoidZ = { {center = riverZ, margin = 40} },
        minScale = 0.8, maxScale = 1.3,
        yawOnly = true,
    })
end

