local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AssignJob = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AssignJob")

-- Minimal placeholder: press keys to send job requests
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.H then
        AssignJob:FireServer({type="Haul"})
    elseif input.KeyCode == Enum.KeyCode.F then
        AssignJob:FireServer({type="Farm"})
    end
end)
