local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:FindFirstChild("AdventureRemotes") or Instance.new("Folder")
Remotes.Name = "AdventureRemotes"; Remotes.Parent = RS
local function RE(n) local r = Remotes:FindFirstChild(n) or Instance.new("RemoteEvent") r.Name = n r.Parent = Remotes return r end
local function RF(n) local r = Remotes:FindFirstChild(n) or Instance.new("RemoteFunction") r.Name = n r.Parent = Remotes return r end
RE("UIUpdate"); RF("DialogRF"); RF("PurchaseRF"); RE("ChooseTeam"); RE("ObjectiveUpdate")

