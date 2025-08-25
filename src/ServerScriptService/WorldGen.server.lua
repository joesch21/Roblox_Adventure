-- WorldGen.server.lua
-- Drops a quick playable world: forest, mountains, a castle (Knights) and a camp (Barbarians)

local World = workspace:FindFirstChild("World") or Instance.new("Folder")
World.Name = "World"; World.Parent = workspace

local function mkPart(name, size, cframe, color, material, anchored, parent)
local p = Instance.new("Part")
p.Name = name
p.Size = size
p.CFrame = cframe
p.Color = color or Color3.fromRGB(120,120,120)
p.Material = material or Enum.Material.Slate
p.Anchored = anchored ~= false
p.TopSurface = Enum.SurfaceType.Smooth
p.BottomSurface = Enum.SurfaceType.Smooth
p.Parent = parent or World
return p
end

-- Flat base so coins/NPCs don’t fall
local base = mkPart("Ground", Vector3.new(500, 2, 500), CFrame.new(0, 0, 0), Color3.fromRGB(58, 125, 21), Enum.Material.Grass)
base.Locked = true

-- Forest
local Forest = Instance.new("Folder"); Forest.Name = "Forest"; Forest.Parent = World
local function mkTree(pos: Vector3)
local trunk = mkPart("Trunk", Vector3.new(2, 12, 2), CFrame.new(pos + Vector3.new(0,6,0)), Color3.fromRGB(101,67,33), Enum.Material.Wood)
trunk.Shape = Enum.PartType.Cylinder; trunk.Orientation = Vector3.new(0,0,90)
local leaves = Instance.new("Part")
leaves.Name="Leaves"; leaves.Size=Vector3.new(8,6,8); leaves.Shape=Enum.PartType.Ball
leaves.Color = Color3.fromRGB(41, 121, 41); leaves.Material = Enum.Material.Grass; leaves.Anchored = true
leaves.CFrame = CFrame.new(pos + Vector3.new(0,14,0)); leaves.Parent = Forest
trunk.Parent = Forest
end
math.randomseed(os.time())
for i=1,45 do
local x = math.random(-200, -40)
local z = math.random(-200, 200)
mkTree(Vector3.new(x, 1, z))
end

-- Mountains (simple rock piles)
local Mountains = Instance.new("Folder"); Mountains.Name = "Mountains"; Mountains.Parent = World
for i=1,14 do
local x = math.random(60, 220)
local z = math.random(-220, 220)
local height = math.random(20, 50)
local steps = math.random(3,6)
for s=1,steps do
local size = Vector3.new(math.max(14 - s*2, 6), height/steps, math.max(14 - s*2, 6))
local y = (height/steps)*s
mkPart("RockStep", size, CFrame.new(x + math.random(-4,4), y, z + math.random(-4,4)), Color3.fromRGB(110,110,110), Enum.Material.Rock, true, Mountains)
end
end

-- Knight castle (very blocky but fast)
local Castle = Instance.new("Folder"); Castle.Name = "Castle"; Castle.Parent = World
local castleCenter = Vector3.new(120, 1, 0)
-- walls
mkPart("WallN", Vector3.new(80, 18, 4), CFrame.new(castleCenter + Vector3.new(0, 9, -40)), Color3.fromRGB(150,150,150), Enum.Material.Concrete, true, Castle)
mkPart("WallS", Vector3.new(80, 18, 4), CFrame.new(castleCenter + Vector3.new(0, 9,  40)), Color3.fromRGB(150,150,150), Enum.Material.Concrete, true, Castle)
mkPart("WallE", Vector3.new(4, 18, 80), CFrame.new(castleCenter + Vector3.new(40, 9, 0)),  Color3.fromRGB(150,150,150), Enum.Material.Concrete, true, Castle)
mkPart("WallW", Vector3.new(4, 18, 80), CFrame.new(castleCenter + Vector3.new(-40, 9, 0)), Color3.fromRGB(150,150,150), Enum.Material.Concrete, true, Castle)
-- keep
mkPart("Keep", Vector3.new(20, 24, 20), CFrame.new(castleCenter + Vector3.new(0, 12, 0)), Color3.fromRGB(170,170,170), Enum.Material.Concrete, true, Castle)
-- knight spawn
local knightSpawn = Instance.new("SpawnLocation")
knightSpawn.Name = "KnightSpawn"; knightSpawn.Position = castleCenter + Vector3.new(-10, 6, 0)
knightSpawn.Size = Vector3.new(6,1,6); knightSpawn.Anchored = true; knightSpawn.Neutral = false
knightSpawn.BrickColor = BrickColor.new("Bright blue"); knightSpawn.Parent = Castle

-- Barbarian camp
local Camp = Instance.new("Folder"); Camp.Name = "BarbarianCamp"; Camp.Parent = World
local campCenter = Vector3.new(-120, 1, 0)
-- totems / tents
for i=1,5 do
local offset = Vector3.new(i*6 - 15, 0, math.random(-10,10))
mkPart("Totem"..i, Vector3.new(2, 10, 2), CFrame.new(campCenter + offset + Vector3.new(0,5,0)), Color3.fromRGB(139,69,19), Enum.Material.Wood, true, Camp)
end
-- campfire
local fireBase = mkPart("CampFire", Vector3.new(6,1,6), CFrame.new(campCenter + Vector3.new(0,1,0)), Color3.fromRGB(90,50,30), Enum.Material.Wood, true, Camp)
-- barbarian spawn
local barbSpawn = Instance.new("SpawnLocation")
barbSpawn.Name = "BarbarianSpawn"; barbSpawn.Position = campCenter + Vector3.new(10, 6, 0)
barbSpawn.Size = Vector3.new(6,1,6); barbSpawn.Anchored = true; barbSpawn.Neutral = false
barbSpawn.BrickColor = BrickColor.new("Bright red"); barbSpawn.Parent = Camp
