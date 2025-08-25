-- TeamSelect.client.lua
-- Minimal team selection UI that talks to Teams.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Remotes = ReplicatedStorage:WaitForChild("AdventureRemotes")
local ChooseTeam = Remotes:WaitForChild("ChooseTeam")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui"); gui.Name = "TeamPicker"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame"); frame.Size = UDim2.fromOffset(360, 140); frame.Position = UDim2.new(0.5, -180, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30); frame.Parent = gui
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,10); corner.Parent = frame

local title = Instance.new("TextLabel"); title.Size = UDim2.fromOffset(340, 30); title.Position = UDim2.fromOffset(10, 10)
title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(240,240,255); title.Font = Enum.Font.GothamBold; title.TextSize = 20
title.Text = "Choose your side"; title.Parent = frame

local knights = Instance.new("TextButton"); knights.Size = UDim2.fromOffset(150, 50); knights.Position = UDim2.fromOffset(20, 70)
knights.Text = "Join Knights"; knights.BackgroundColor3 = BrickColor.new("Bright blue").Color
local knCorner = Instance.new("UICorner"); knCorner.CornerRadius = UDim.new(0,8); knCorner.Parent = knights
knights.Parent = frame

local barbs = Instance.new("TextButton"); barbs.Size = UDim2.fromOffset(150, 50); barbs.Position = UDim2.fromOffset(190, 70)
barbs.Text = "Join Barbarians"; barbs.BackgroundColor3 = BrickColor.new("Bright red").Color
local bbCorner = Instance.new("UICorner"); bbCorner.CornerRadius = UDim.new(0,8); bbCorner.Parent = barbs
barbs.Parent = frame

local function choose(which)
ChooseTeam:FireServer(which)
gui.Enabled = false -- dismiss after pick
end

knights.MouseButton1Click:Connect(function() choose("Knights") end)
barbs.MouseButton1Click:Connect(function() choose("Barbarians") end)
