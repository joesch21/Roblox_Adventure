local Config = require(script.Parent["_Config.module"])

local Rules = {
  Castle = {
    folder    = "Castle",
    count     = 1,
    minScale  = Config.CASTLE_SCALE,
    maxScale  = Config.CASTLE_SCALE,
    yawOnly   = true,
    fixedPos  = Config.CASTLE_POS,
    fixedYaw  = Config.CASTLE_YAW, -- degrees
  },
  Village = { folder="Village", count=1, minScale=1.0, maxScale=1.0, yawOnly=true },
  Barbarian = { folder="BarbarianCamp", count=1, minScale=1.0, maxScale=1.0, yawOnly=true },

  Tree = {
    folder   = "Nature", count = 25,
    area     = Config.SCATTER_AREA,
    minScale = 0.9, maxScale = 1.25, yawOnly = true,
  },
  Rock = {
    folder   = "Nature", count = 12,
    area     = Config.SCATTER_AREA,
    minScale = 0.85, maxScale = 1.2, yawOnly = true,
  },
  NPC  = { folder="Village", count=1, minScale=1.0, maxScale=1.0, yawOnly=true },
  Prop = { folder="Village", count=3, minScale=1.0, maxScale=1.0, yawOnly=true },
}

Rules.__default = Rules.__default or {
  folder = "Nature", count = 1,
  area = Config.SCATTER_AREA, minScale = 1.0, maxScale = 1.0, yawOnly = true,
}

return Rules

