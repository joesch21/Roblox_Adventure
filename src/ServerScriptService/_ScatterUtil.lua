-- _ScatterUtil.lua
-- Small helpers to scatter prefab Models with variation.

local Scatter = {}

local function randomBetween(a,b) return a + math.random()*(b-a) end

function Scatter.scatterModels(args)
    -- args: { folder:Folder, parent:Instance, count:number, areaMin:Vector3, areaMax:Vector3,
    --         avoidZ = {{center:number, margin:number}, ...} (optional),
    --         minScale:number (optional), maxScale:number (optional),
    --         yawOnly:boolean (default true) }
    local folder = args.folder
    if not folder or #folder:GetChildren() == 0 then
        if not Scatter._warned then
            warn("[WorldGen] No prefabs found in ReplicatedStorage/Models/Trees or /Rocks; skipping scatter.")
            Scatter._warned = true
        end
        return
    end
    local parent = args.parent or workspace
    local minS, maxS = args.minScale or 0.9, args.maxScale or 1.2
    local yawOnly = args.yawOnly ~= false
    local avoidZ = args.avoidZ or {}

    for i = 1, args.count or 0 do
        local prefab = folder:GetChildren()[math.random(1, #folder:GetChildren())]
        local x = randomBetween(args.areaMin.X, args.areaMax.X)
        local z = randomBetween(args.areaMin.Z, args.areaMax.Z)

        -- skip forbidden Z bands (e.g., river)
        local blocked = false
        for _,band in ipairs(avoidZ) do
            if math.abs(z - band.center) <= (band.margin or 20) then blocked = true break end
        end
        if blocked then continue end

        local model = prefab:Clone()
        for _,d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
                d.CanQuery = false
                d.CanTouch = false
            end
        end

        if not model.PrimaryPart then
            local any = model:FindFirstChildOfClass("BasePart")
            if any then model.PrimaryPart = any end
        end
        if not model.PrimaryPart then model:Destroy(); continue end

        local cf = CFrame.new(x, 1, z)
        if yawOnly then
            cf *= CFrame.Angles(0, math.rad(math.random(0,359)), 0)
        else
            cf *= CFrame.Angles(math.rad(math.random(-2,2)), math.rad(math.random(0,359)), 0)
        end
        model:PivotTo(cf)

        -- MeshParts will scale; regular Parts won’t (that’s fine for most Creator Store trees)
        local scale = randomBetween(minS, maxS)
        for _,d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Size = d.Size * scale
            end
        end

        model.Parent = parent
    end
end

return Scatter


