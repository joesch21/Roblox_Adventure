local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RequestBuild = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestBuild")
local Config = require(ReplicatedStorage.Modules.Config)

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "BuildMenu"
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,300)
frame.Position = UDim2.new(0,10,0,40)
frame.Parent = gui
gui.Parent = player:WaitForChild("PlayerGui")

local y = 0
for name,_ in pairs(Config.BUILD_COSTS) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,30)
    button.Position = UDim2.new(0,0,0,y)
    button.Text = name
    button.Parent = frame
    y = y + 30
    button.MouseButton1Click:Connect(function()
        local pos = Vector3.new(0,0,0)
        RequestBuild:FireServer(name, pos)
    end)
end
