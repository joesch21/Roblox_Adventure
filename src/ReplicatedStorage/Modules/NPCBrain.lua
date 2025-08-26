local FactionState = require(script.Parent.FactionState)
local Pathing = require(script.Parent.Pathing)

local NPCBrain = {}

local handlers = {}

function handlers.Build(npc, job, faction)
    local ServerStorage = game:GetService("ServerStorage")
    local prefabFolder = ServerStorage:FindFirstChild("Prefabs")
    if not prefabFolder then return end
    local model = prefabFolder:FindFirstChild("Buildings")
    model = model and model:FindFirstChild(job.prefab)
    if model then
        local clone = model:Clone()
        clone:SetPrimaryPartCFrame(CFrame.new(job.position))
        clone.Parent = workspace
    end
end

function NPCBrain.Init(npc, faction)
    local state = FactionState.Get(faction)
    npc:SetAttribute("Busy", false)
    task.spawn(function()
        while npc.Parent do
            local job = state.JobQueue:pop()
            if job then
                npc:SetAttribute("Busy", true)
                if job.position and npc.PrimaryPart then
                    Pathing.GoTo(npc, job.position)
                end
                local handler = handlers[job.type]
                if handler then
                    handler(npc, job, faction)
                end
                npc:SetAttribute("Busy", false)
            else
                task.wait(1)
            end
        end
    end)
end

return NPCBrain
