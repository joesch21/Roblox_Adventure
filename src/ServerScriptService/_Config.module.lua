local RunService = game:GetService("RunService")

return {
  BAKE_MODE = false,                -- true: rebuild Spawned in Edit mode so you can save
  SKIP_DATASTORE_IN_STUDIO = true,  -- unrelated here, kept to silence Studio saves

  SCATTER_AREA = {
    min = Vector3.new(-380, 0, -380),
    max = Vector3.new( 380, 0,  380),
  },

  AVOID_BANDS = {
    -- Example: { axis = "Z", center = -40, margin = 50 },
  },

  -- Castle global controls:
  CASTLE_SCALE = 1.6,                         -- make castle bigger (uniform)
  CASTLE_POS   = Vector3.new(180, 0, 40),     -- spawn position
  CASTLE_YAW   = 0,                           -- degrees
}

