local Config = require(script.Parent.Config)
local JobQueue = require(script.Parent.JobQueue)

local states = {}

local FactionState = {}

local function cloneTable(t)
    local c = {}
    for k,v in pairs(t) do c[k]=v end
    return c
end

local function init(name)
    local st = {
        Players = {},
        NPCs = {},
        Resources = cloneTable(Config.START_RESOURCES),
        JobQueue = JobQueue.new(),
        Tech = {GunpowderAge=false},
        Population = 0,
    }
    states[name] = st
    return st
end

function FactionState.Get(name)
    return states[name] or init(name)
end

return FactionState
