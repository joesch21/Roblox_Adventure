local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RequestBuild = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestBuild")

local Config = require(ReplicatedStorage.Modules.Config)
local FactionState = require(ReplicatedStorage.Modules.FactionState)
local Economy = require(ReplicatedStorage.Modules.Economy)

local function teamNameOf(player)
    return player.Team and player.Team.Name
end

RequestBuild.OnServerEvent:Connect(function(player, buildingName, position)
    if not Config.Flags.NewNPCs then return end
    local tname = teamNameOf(player); if not tname then return end
    if not Config.BUILD_COSTS[buildingName] then return end

    local st = FactionState.Get(tname)
    local cost = Config.BUILD_COSTS[buildingName]

    if buildingName == "Cannon" and not (st.Tech and st.Tech.GunpowderAge) then
        return
    end

    if Economy.HasResources(st.Resources, cost) then
        Economy.Pay(st.Resources, cost)
        st.JobQueue:push({
            type = "Build", prefab = buildingName, position = position,
            priority = Config.JOB_PRIORITIES.BuildCoreEcon
        })
        st.Built = st.Built or {}
        st.Built[buildingName] = true
    end
end)
