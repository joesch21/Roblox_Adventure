local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LobbyStatus = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LobbyStatus")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "LobbyBanner"
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,0,30)
label.Text = "Waiting for players..."
label.Parent = gui
gui.Parent = player:WaitForChild("PlayerGui")

LobbyStatus.OnClientEvent:Connect(function(data)
    if player.Team and player.Team.Name == "Spectator" then
        label.Text = "Waiting for an even player count."
    else
        label.Text = string.format("Atk:%d Def:%d Total:%d Even:%s", data.attackers, data.defenders, data.total, tostring(data.evenReady))
    end
end)
