local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Modules.Config)
local FactionState = require(ReplicatedStorage.Modules.FactionState)
local NPCBrain = require(ReplicatedStorage.Modules.NPCBrain)

local WorkerPrefab = ServerStorage:WaitForChild("Prefabs"):WaitForChild("Units"):WaitForChild("WorkerNPC", 0)

local function clamp(n,a,b) return math.max(a, math.min(b,n)) end

local function budget(players)
    local s = Config.NPC_SCALING
    local p = math.max(1, players)
    return clamp(math.ceil(s.BASE_NPC*(s.P_REF/p)), s.MIN_NPC, s.MAX_NPC)
end

local function ensureNPCs(faction)
    local st = FactionState.Get(faction)
    local want = budget(#st.Players)
    local have = #st.NPCs

    if have < want then
        for _ = 1,(want-have) do
            if WorkerPrefab then
                local npc = WorkerPrefab:Clone()
                npc.Parent = workspace:FindFirstChild(faction.."Units") or workspace
                table.insert(st.NPCs, npc)
                NPCBrain.Init(npc, faction)
            end
        end
    elseif have > want then
        for i = have, want+1, -1 do
            local npc = table.remove(st.NPCs)
            if npc then npc:Destroy() end
        end
    end
end

RunService.Heartbeat:Connect(function()
    for _, f in ipairs(Config.FACTIONS) do
        ensureNPCs(f)
    end
end)
