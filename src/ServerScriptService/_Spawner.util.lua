local Spawner = {}

local function ensurePrimary(model: Instance)
  if model.PrimaryPart then return end
  local any = model:FindFirstChildOfClass("BasePart")
  if any then model.PrimaryPart = any end
end

function Spawner.CloneAt(prefab: Instance, parent: Instance, cf: CFrame, minScale: number?, maxScale: number?)
  if not prefab then return nil end
  local m = prefab:Clone()
  ensurePrimary(m)
  if m.PrimaryPart then m:PivotTo(cf) end
  local smin, smax = minScale or 1.0, maxScale or 1.0
  local scale = (smin == smax) and smin or (smin + math.random()*(smax - smin))
  for _,d in ipairs(m:GetDescendants()) do
    if d:IsA("BasePart") then
      d.Anchored = true
      d.Size = d.Size * scale
    end
  end
  m.Parent = parent
  return m
end

return Spawner

