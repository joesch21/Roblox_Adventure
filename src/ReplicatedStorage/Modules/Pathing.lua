local Pathing = {}

function Pathing.GoTo(model, position)
    if not (model and model.PrimaryPart) then return end
    model:MoveTo(position)
    local reached = Instance.new("BindableEvent")
    local conn
    conn = model.MoveToFinished:Connect(function(reachedGoal)
        if conn then conn:Disconnect() end
        reached:Fire(reachedGoal)
    end)
    reached.Event:Wait()
end

return Pathing
