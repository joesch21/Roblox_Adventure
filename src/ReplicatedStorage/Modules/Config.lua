local Config = {}

Config.FACTIONS = {"Attacker","Defender"}

Config.NPC_SCALING = { BASE_NPC=20, P_REF=2, MIN_NPC=6, MAX_NPC=22 }

Config.START_RESOURCES = { Coins=250, Wood=200, Stone=120, Iron=60, Coal=30, Food=120 }

Config.BUILD_COSTS = {
  Farm={Wood=40, Coins=20},
  Mine={Wood=30, Stone=10, Coins=20},
  Blacksmith={Wood=40, Stone=40, Iron=10, Coins=40},
  House={Wood=30, Stone=10},
  Granary={Wood=20, Stone=30},
  Market={Wood=50, Stone=30, Coins=60},
  Dock={Wood=60, Stone=20, Coins=50},
  Wall={Stone=20},
  Tower={Stone=50, Iron=5, Coins=25},
  Cannon={Iron=30, Coal=20, Stone=40, Coins=120},
}

Config.JOB_PRIORITIES = { RepairWall=100, BuildDefense=95, DeliverSiege=90, BuildCoreEcon=80, HaulGoods=60, Farm=50, Mine=50, Smithing=50, TradeRun=45 }

Config.Flags = { NewMatchmaker=true, NewEconomy=true, NewNPCs=true }

return Config
