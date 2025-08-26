local JobQueue = {}
JobQueue.__index = JobQueue

function JobQueue.new()
    return setmetatable({items={}}, JobQueue)
end

function JobQueue:push(job)
    table.insert(self.items, job)
    table.sort(self.items, function(a,b)
        return (a.priority or 0) > (b.priority or 0)
    end)
end

function JobQueue:pop()
    return table.remove(self.items, 1)
end

return JobQueue
