-- Teams.server.lua
-- Knights vs Barbarians selection + spawning

local Players = game:GetService("Players")
local TeamsService = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Teams
local Knights = TeamsService:FindFirstChild("Knights") or Instance.new("Team")
Knights.Name = "Knights"; Knights.TeamColor = BrickColor.new("Bright blue"); Knights.AutoAssignable = false; Knights.Parent = TeamsService

local Barbarians = TeamsService:FindFirstChild("Barbarians") or Instance.new("Team")
Barbarians.Name = "Barbarians"; Barbarians.TeamColor = BrickColor.new("Bright red"); Barbarians.AutoAssignable = false; Barbarians.Parent = TeamsService

-- Remote to choose team
local Remotes = ReplicatedStorage:FindFirstChild("AdventureRemotes") or Instance.new("Folder")
Remotes.Name = "AdventureRemotes"; Remotes.Parent = ReplicatedStorage
local ChooseTeam = Remotes:FindFirstChild("ChooseTeam") or Instance.new("RemoteEvent")
ChooseTeam.Name = "ChooseTeam"; ChooseTeam.Parent = Remotes

-- Locate spawns (from WorldGen)
local function getSpawnForTeam(team: Team)
local spawn
if team == Knights then
spawn = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Castle") and workspace.World.Castle:FindFirstChild("KnightSpawn")
elseif team == Barbarians then
spawn = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("BarbarianCamp") and workspace.World.BarbarianCamp:FindFirstChild("BarbarianSpawn")
end
return spawn
end

ChooseTeam.OnServerEvent:Connect(function(plr, which: string)
local target = (which == "Knights") and Knights or Barbarians
plr.Team = target
-- move them to their spawn if alive
if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
local sp = getSpawnForTeam(target)
if sp then
plr.Character.HumanoidRootPart.CFrame = CFrame.new(sp.Position + Vector3.new(0, 5, 0))
end
end
end)

-- When a player spawns after choosing team, keep them near their base
Players.PlayerAdded:Connect(function(plr)
plr.CharacterAdded:Connect(function(char)
task.wait(0.2)
if plr.Team then
local sp = getSpawnForTeam(plr.Team)
if sp and char:FindFirstChild("HumanoidRootPart") then
char.HumanoidRootPart.CFrame = CFrame.new(sp.Position + Vector3.new(0, 5, 0))
end
end
end)
end)
