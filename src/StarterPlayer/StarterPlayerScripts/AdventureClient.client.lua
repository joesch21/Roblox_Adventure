-- AdventureClient
-- Handles HUD, shop UI, and dialog

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Remotes = ReplicatedStorage:WaitForChild("AdventureRemotes")
local UIUpdate = Remotes:WaitForChild("UIUpdate")
local DialogRF = Remotes:WaitForChild("DialogRF")
local PurchaseRF = Remotes:WaitForChild("PurchaseRF")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "AdventureHUD"
gui.Parent = player:WaitForChild("PlayerGui")

-- HUD
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(0,200,0,30)
coinsLabel.Position = UDim2.new(0,10,0,10)
coinsLabel.TextColor3 = Color3.new(1,1,1)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text = "Gold: 0"

coinsLabel.Parent = gui

local questLabel = Instance.new("TextLabel")
questLabel.Size = UDim2.new(0,300,0,30)
questLabel.Position = UDim2.new(0,10,0,40)
questLabel.TextColor3 = Color3.new(1,1,1)
questLabel.BackgroundTransparency = 1
questLabel.Text = "No quest"
questLabel.Parent = gui

-- Shop button
local shopBtn = Instance.new("TextButton")
shopBtn.Size = UDim2.new(0,120,0,40)
shopBtn.Position = UDim2.new(0,10,0,80)
shopBtn.Text = "Open Shop"
shopBtn.Parent = gui

local shopFrame = Instance.new("Frame")
shopFrame.Size = UDim2.new(0,250,0,150)
shopFrame.Position = UDim2.new(0,10,0,130)
shopFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
shopFrame.Visible = false
shopFrame.Parent = gui

local buySword = Instance.new("TextButton")
buySword.Size = UDim2.new(0,200,0,40)
buySword.Position = UDim2.new(0,25,0,50)
buySword.Text = "Buy Sword (10 coins)"
buySword.Parent = shopFrame

shopBtn.MouseButton1Click:Connect(function()
	shopFrame.Visible = not shopFrame.Visible
end)

buySword.MouseButton1Click:Connect(function()
	local result = PurchaseRF:InvokeServer("Sword")
	if result and result.message then
		StarterGui:SetCore("SendNotification", {
			Title = result.ok and "Success" or "Shop",
			Text = result.message,
			Duration = 2
		})
	end
end)

-- UI updates from server
UIUpdate.OnClientEvent:Connect(function(data)
	if data.coins then
		coinsLabel.Text = "Coins: "..data.coins
	end
	if data.quests then
		local cc = data.quests.CoinCollector
		local fb = data.quests.FirstBlood
		local txt = {}
		if cc then
			table.insert(txt, "Coin Collector: "..cc.progress.."/10 ("..cc.state..")")
		end
		if fb then
			table.insert(txt, "First Blood: "..fb.progress.."/3 ("..fb.state..")")
		end
		questLabel.Text = table.concat(txt, " | ")
	end
end)
