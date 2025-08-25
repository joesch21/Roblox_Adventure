-- AdventureServer
-- Handles player data, coins, quests, shop, combat, and enemy AI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- Config
local COIN_VALUE = 1
local QUESTS = {
	CoinCollector = { target = 10, reward = 20 },
	FirstBlood = { target = 3, reward = 30 }
}

-- Remotes
local Remotes = Instance.new("Folder")
Remotes.Name = "AdventureRemotes"
Remotes.Parent = ReplicatedStorage

local UIUpdate = Instance.new("RemoteEvent")
UIUpdate.Name = "UIUpdate"
UIUpdate.Parent = Remotes

local DialogRF = Instance.new("RemoteFunction")
DialogRF.Name = "DialogRF"
DialogRF.Parent = Remotes

local PurchaseRF = Instance.new("RemoteFunction")
PurchaseRF.Name = "PurchaseRF"
PurchaseRF.Parent = Remotes

-- Data
local Profiles = {}
local DataStore
pcall(function() DataStore = DataStoreService:GetDataStore("Adventure_Save_v1") end)

local DEFAULT_DATA = {
	coins = 0,
	quests = {
		CoinCollector = { state = "not_started", progress = 0 },
		FirstBlood = { state = "not_started", progress = 0 }
	},
	items = {}
}

local function deepCopy(t)
	local n = {}
	for k,v in pairs(t) do
		if type(v) == "table" then n[k] = deepCopy(v) else n[k] = v end
	end
	return n
end

local function getProfile(plr) return Profiles[plr.UserId] end

local function saveProfile(plr)
	if not DataStore then return end
	local p = Profiles[plr.UserId]
	if p then
		pcall(function()
			DataStore:SetAsync("Player_"..plr.UserId, p)
		end)
	end
end

local function loadProfile(plr)
	local profile = deepCopy(DEFAULT_DATA)
	if DataStore then
		local ok, data = pcall(function()
			return DataStore:GetAsync("Player_"..plr.UserId)
		end)
		if ok and type(data) == "table" then
			for k,v in pairs(data) do profile[k] = v end
		end
	end
	Profiles[plr.UserId] = profile
end

-- UI update
local function pumpUI(plr)
	local p = getProfile(plr)
	if p then
		UIUpdate:FireClient(plr, {
			coins = p.coins,
			quests = p.quests
		})
	end
end

-- Quests
local function onCoinCollected(plr)
	local q = getProfile(plr).quests.CoinCollector
	if q.state == "in_progress" then
		q.progress += 1
		if q.progress >= QUESTS.CoinCollector.target then
			q.state = "completed"
			getProfile(plr).coins += QUESTS.CoinCollector.reward
		end
	end
	pumpUI(plr)
end

local function onEnemyDefeated(plr)
	local q = getProfile(plr).quests.FirstBlood
	if q.state == "in_progress" then
		q.progress += 1
		if q.progress >= QUESTS.FirstBlood.target then
			q.state = "completed"
			getProfile(plr).coins += QUESTS.FirstBlood.reward
		end
	end
	pumpUI(plr)
end

-- NPC dialog
DialogRF.OnServerInvoke = function(plr, npcName)
	local p = getProfile(plr)
	if npcName == "QuestGiver" then
		local cc = p.quests.CoinCollector
		local fb = p.quests.FirstBlood
		if cc.state == "not_started" then
			cc.state = "in_progress"
			return { title = "Coin Collector", lines = { "Collect 10 coins!" } }
		elseif cc.state == "in_progress" then
			return { title = "Coin Collector", lines = { ("Progress %d/10"):format(cc.progress) } }
		elseif cc.state == "completed" and fb.state == "not_started" then
			fb.state = "in_progress"
			return { title = "First Blood", lines = { "Defeat 3 enemies!" } }
		elseif fb.state == "in_progress" then
			return { title = "First Blood", lines = { ("Progress %d/3"):format(fb.progress) } }
		else
			return { title = "Done!", lines = { "All quests completed." } }
		end
	end
	return { title = "NPC", lines = { "Hello!" } }
end

-- Shop
PurchaseRF.OnServerInvoke = function(plr, itemId)
	local p = getProfile(plr)
	if itemId == "Sword" and not p.items.Sword then
		if p.coins >= 10 then
			p.coins -= 10
			p.items.Sword = true
			local tool = Instance.new("Tool")
			tool.Name = "Sword"
			tool.RequiresHandle = true
			local h = Instance.new("Part")
			h.Name = "Handle"
			h.Size = Vector3.new(1,4,1)
			h.Parent = tool
			tool.Parent = plr.Backpack
			return { ok = true, message = "Bought a Sword!" }
		else
			return { ok = false, message = "Not enough coins!" }
		end
	end
	return { ok = false, message = "Invalid item" }
end

-- Coins (simple scattered parts)
local CoinsFolder = Instance.new("Folder")
CoinsFolder.Name = "Coins"
CoinsFolder.Parent = workspace

for i=1,15 do
	local coin = Instance.new("Part")
	coin.Shape = Enum.PartType.Cylinder
	coin.Size = Vector3.new(1.5,0.3,1.5)
	coin.Orientation = Vector3.new(0,0,90)
	coin.Position = Vector3.new(math.random(-50,50),5,math.random(-50,50))
	coin.Anchored = false
	coin.CanCollide = false
	coin.Color = Color3.new(1,1,0)
	coin.Parent = CoinsFolder
	coin.Touched:Connect(function(hit)
		local plr = Players:GetPlayerFromCharacter(hit.Parent)
		if plr and coin.Parent then
			coin:Destroy()
			getProfile(plr).coins += COIN_VALUE
			onCoinCollected(plr)
		end
	end)
end

-- Player lifecycle
Players.PlayerAdded:Connect(function(plr)
	loadProfile(plr)
	plr.CharacterAdded:Connect(function()
		pumpUI(plr)
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	saveProfile(plr)
	Profiles[plr.UserId] = nil
end)
