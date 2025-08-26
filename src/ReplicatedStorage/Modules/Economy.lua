local Economy = {}

function Economy.HasResources(res, cost)
    for k,v in pairs(cost) do
        if (res[k] or 0) < v then
            return false
        end
    end
    return true
end

function Economy.Pay(res, cost)
    for k,v in pairs(cost) do
        res[k] = (res[k] or 0) - v
    end
end

function Economy.Add(res, delta)
    for k,v in pairs(delta) do
        res[k] = (res[k] or 0) + v
    end
end

function Economy.TickPopulation(state)
    local pop = state.Population or 0
    local upkeep = pop
    state.Resources.Food = (state.Resources.Food or 0) - upkeep
    local tax = math.floor(pop/2)
    state.Resources.Coins = (state.Resources.Coins or 0) + tax
end

function Economy.ApplyTradeRoutes(state)
    -- placeholder for future trade logic
end

function Economy.UnlockTech(state, tech)
    if tech == "GunpowderAge" then
        if state.Tech.GunpowderAge then return end
        if state.Built and state.Built.Blacksmith and state.Built.Market and state.Built.Dock then
            state.Tech.GunpowderAge = true
        end
    end
end

return Economy
