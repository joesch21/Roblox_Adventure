-- Maps name prefixes to World folders + default spawn rules.
-- Example: a model named "Castle_Tower" → prefix "Castle" → goes to World/Castle.
-- A model named "Tree_Pine" or just "Tree" → prefix "Tree" → goes to World/Nature.

local Config = require(script.Parent["_Config.module"])

local Rules = {
    -- prefix = { folder = "<WorldSubfolder>", count = n, area = {min=V3,max=V3}, minScale=0.95, maxScale=1.1, yawOnly=true }
    Castle = {
        folder   = "Castle",
        count    = 1,
        minScale = 1.0, maxScale = 1.0,
        yawOnly  = true,
    },
    Village = {
        folder   = "Village",
        count    = 1,
        minScale = 1.0, maxScale = 1.0,
        yawOnly  = true,
    },
    Barbarian = {        -- e.g., "Barbarian_Tent"
        folder   = "BarbarianCamp",
        count    = 1,
        minScale = 1.0, maxScale = 1.0,
        yawOnly  = true,
    },
    Tree = {
        folder   = "Nature",
        count    = 25,
        area     = Config.SCATTER_AREA,
        minScale = 0.9, maxScale = 1.25,
        yawOnly  = true,
    },
    Rock = {
        folder   = "Nature",
        count    = 12,
        area     = Config.SCATTER_AREA,
        minScale = 0.85, maxScale = 1.2,
        yawOnly  = true,
    },
    Prop = {
        folder   = "Village",
        count    = 3,
        area     = Config.SCATTER_AREA,
        minScale = 1.0, maxScale = 1.0,
        yawOnly  = true,
    },
    NPC = {
        folder   = "Village",
        count    = 1,
        minScale = 1.0, maxScale = 1.0,
        yawOnly  = true,
    },
}

-- Fallback when no prefix matches: drop into Nature, count=1
Rules.__default = {
    folder   = "Nature",
    count    = 1,
    area     = Config.SCATTER_AREA,
    minScale = 1.0, maxScale = 1.0,
    yawOnly  = true,
}

return Rules

