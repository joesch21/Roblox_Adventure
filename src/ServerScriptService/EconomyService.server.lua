local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Modules.Config)
local FactionState = require(ReplicatedStorage.Modules.FactionState)
local Economy = require(ReplicatedStorage.Modules.Economy)

local StatePush = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StatePush")

local function tickFaction(name)
    local state = FactionState.Get(name)
    Economy.TickPopulation(state)
    Economy.ApplyTradeRoutes(state)
    Economy.UnlockTech(state, "GunpowderAge")
    StatePush:FireAllClients(name, {
        resources = state.Resources,
        pop = state.Population,
        tech = state.Tech,
    })
end

while true do
    task.wait(5)
    for _, f in ipairs(Config.FACTIONS) do
        tickFaction(f)
    end
end
