local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local LobbyStatus = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LobbyStatus")
local Config = require(ReplicatedStorage.Modules.Config)

local teams = { Attacker = {}, Defender = {} }
local waitingQueue = {}

local function total()
    return #teams.Attacker + #teams.Defender
end

local function inTable(t, p)
    for i, x in ipairs(t) do
        if x == p then return i end
    end
    return nil
end

local function assignTeam(player)
    if #teams.Attacker <= #teams.Defender then
        table.insert(teams.Attacker, player)
        player.Team = Teams:WaitForChild("Attacker")
    else
        table.insert(teams.Defender, player)
        player.Team = Teams:WaitForChild("Defender")
    end
end

local function removePlayer(player)
    for _, list in pairs(teams) do
        local idx = inTable(list, player)
        if idx then table.remove(list, idx) end
    end
    local q = inTable(waitingQueue, player)
    if q then table.remove(waitingQueue, q) end
end

local function broadcast()
    LobbyStatus:FireAllClients({
        attackers = #teams.Attacker,
        defenders = #teams.Defender,
        total = total(),
        evenReady = (total() % 2 == 0 and total() >= 2)
    })
end

Players.PlayerAdded:Connect(function(player)
    if (total() % 2) == 1 then
        table.insert(waitingQueue, player)
        player.Team = Teams:WaitForChild("Spectator")
    else
        assignTeam(player)
    end
    broadcast()
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayer(player)
    if (total() % 2) == 1 and #waitingQueue > 0 then
        local promote = table.remove(waitingQueue, 1)
        assignTeam(promote)
    end
    broadcast()
end)

return teams
