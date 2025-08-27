local RunService = game:GetService("RunService")

return {
    BAKE_MODE = false,               -- true: generate in Edit mode (no Play), then you can save
    SKIP_DATASTORE_IN_STUDIO = true, -- unrelated here; kept for consistency

    -- Global default scatter area (X/Z bounds) if a rule doesn't specify its own:
    SCATTER_AREA = {
        min = Vector3.new(-380, 0, -380),
        max = Vector3.new( 380, 0,  380),
    },

    -- A band to avoid (e.g., river at Z = -40); empty table = no avoidance
    AVOID_BANDS = {
        -- { axis = "Z", center = -40, margin = 50 },
    },

    -- === NEW: Castle controls ===
    CASTLE_SCALE = 1.6,                         -- uniform scale (1.0 = original; try 1.3–2.0)
    CASTLE_POS   = Vector3.new(180, 0, 40),     -- default castle position
    CASTLE_YAW   = 0,                           -- degrees (0 keeps current facing)
}

