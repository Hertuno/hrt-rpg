-- HRT RPG balance knobs. Tune here; quest targets/rewards stay in roadmap_trees.lua.
-- Required from control and (where noted) data stage.

local Balance = {}

------------------------------------------------------------------------
-- Global pacing / heal
------------------------------------------------------------------------
Balance.tick_interval = 60 -- roadmap + events poll (1 Hz when on_nth_tick(60))

Balance.medkit = {
  radius = 8,
  script_heal = 60, -- AoE heal on top of capsule damage amount
  capsule_heal = -40, -- prototype damage amount (negative = heal)
  cooldown = 60,
  stack_size = 50,
  recipe_time = 2,
  recipe_output = 2,
}

------------------------------------------------------------------------
-- Account / paragons / unlocks
------------------------------------------------------------------------
Balance.account = {
  xp_per_level = 200, -- need = xp_per_level * level
  season_complete_xp = 500,
  class_select_rpg_xp = 50,
  class_select_account_xp = 25,
  subclass_common_rpg_xp = 200,
  subclass_common_account_xp = 100,
  subclass_spec_rpg_xp = 300,
  subclass_spec_account_xp = 150,
}

Balance.class_unlock_level = {
  explorer = 3,
}

Balance.subclass_unlock_level = {
  astronaut = 2,
  cartographer = 3,
  field_scientist = 3,
  vanguard = 2,
  prospector = 2,
  architect = 2,
  overwatch = 2,
}

Balance.paragons = {
  survivor = { character_health_bonus = 25 },
  scout = { character_running_speed_modifier = 0.05 },
  artisan = { character_crafting_speed_modifier = 0.08 },
}

------------------------------------------------------------------------
-- Roadmap engine (not per-quest content)
------------------------------------------------------------------------
Balance.roadmap = {
  default_quest_xp = 50,
  account_xp_from_quest = 0.5, -- fraction of quest.xp
  roadmap_done_account_xp = 200,
  distance_step_max = 40, -- ignore teleport-sized jumps
  deliver_scan_radius = 64,
  chart_poll_mod = 300,
  chart_poll_window = 60,
}

------------------------------------------------------------------------
-- World events
------------------------------------------------------------------------
Balance.events = {
  interval_ticks = 60 * 60 * 18, -- ~18 min
  interval_jitter_ticks = 60 * 60 * 4, -- +0..4 min
  night_check_interval = 60 * 30, -- 30 s
  darkness_threshold = 0.5,

  day_wave = {
    dist_base = 80,
    dist_jitter = 35,
    count_base = 12,
    count_jitter = 8,
    duration_min = 5,
  },
  night_wave = {
    dist_base = 55,
    dist_jitter = 35,
    count_base = 22,
    count_jitter = 12,
    duration_min = 8,
  },
  ore = {
    dist_base = 50,
    dist_jitter = 30,
    tiles = 40,
    amount_base = 100,
    amount_jitter = 200,
    chest_explosives = 20,
    chest_repair = 20,
    duration_min = 10,
  },
  boss_hive = {
    dist_base = 100,
    dist_jitter = 40,
    duration_min = 25,
    nest_clear_radius = 12,
    mix_radius = 48,
    mix_min_classes = 3,
    reward_mix_account_xp = 300,
    reward_solo_account_xp = 80,
    reward_armor = "modular-armor",
    reward_armor_count = 1,
    reward_capsules = "destruction-capsule",
    reward_capsules_count = 5,
  },

  -- Night: night_raid if roll < night_raid_chance
  -- Day/other: hive < hive_chance; else day_wave < day_wave_chance; else ore
  weights = {
    night_raid_chance = 0.55,
    hive_chance = 0.35,
    day_wave_chance = 0.7,
  },
}

------------------------------------------------------------------------
-- Classes: bonuses + starter kits (+ unused damage_bonus reserved)
------------------------------------------------------------------------
Balance.classes = {
  fighter = {
    bonuses = {
      character_health_bonus = 100,
      character_running_speed_modifier = 0.1,
    },
    damage_bonus = 0.15,
    kit = {
      { "hrt-fighter-smg", 1 },
      { "firearm-magazine", 100 },
      { "light-armor", 1 },
      { "gun-turret", 3 },
      { "stone-wall", 50 },
      { "firearm-magazine", 100 },
    },
  },
  miner = {
    bonuses = {
      character_mining_speed_modifier = 0.35,
      character_inventory_slots_bonus = 20,
    },
    kit = {
      { "burner-mining-drill", 4 },
      { "coal", 100 },
      { "transport-belt", 100 },
      { "burner-inserter", 20 },
      { "stone-furnace", 4 },
      { "iron-plate", 50 },
    },
  },
  engineer = {
    bonuses = {
      character_crafting_speed_modifier = 0.4,
      character_inventory_slots_bonus = 30,
      character_build_distance_bonus = 8,
      character_reach_distance_bonus = 6,
    },
    kit = {
      { "assembling-machine-1", 2 },
      { "inserter", 30 },
      { "transport-belt", 100 },
      { "electronic-circuit", 40 },
      { "iron-gear-wheel", 40 },
      { "small-electric-pole", 30 },
    },
  },
  support = {
    bonuses = {
      character_health_bonus = 50,
      character_running_speed_modifier = 0.15,
      character_maximum_following_robot_count_bonus = 5,
    },
    kit = {
      { "defender-capsule", 10 },
      { "repair-pack", 30 },
      { "hrt-medkit", 10 },
      { "construction-robot", 5 },
      { "roboport", 1 },
      { "accumulator", 4 },
      { "solar-panel", 8 },
    },
  },
  explorer = {
    bonuses = {
      character_running_speed_modifier = 0.25,
      character_item_pickup_distance_bonus = 3,
      character_loot_pickup_distance_bonus = 3,
      character_resource_reach_distance_bonus = 2,
      character_inventory_slots_bonus = 10,
    },
    kit = {
      { "automation-science-pack", 50 },
      { "logistic-science-pack", 20 },
      { "lab", 2 },
      { "radar", 2 },
      { "small-lamp", 20 },
      { "electronic-circuit", 30 },
      { "iron-plate", 40 },
      { "copper-plate", 40 },
      { "car", 1 },
    },
  },
}

------------------------------------------------------------------------
-- Subclasses: bonuses + grant items
------------------------------------------------------------------------
Balance.subclasses = {
  logistics = {
    bonuses = {
      character_inventory_slots_bonus = 20,
      character_crafting_speed_modifier = 0.1,
    },
    items = { { "logistic-robot", 5 }, { "steel-chest", 5 } },
  },
  demolitionist = {
    bonuses = { character_health_bonus = 50 },
    items = { { "grenade", 30 }, { "cliff-explosives", 10 }, { "hrt-class-cannon", 1 }, { "rocket", 20 } },
  },
  astronaut = {
    bonuses = {
      character_running_speed_modifier = 0.1,
      character_reach_distance_bonus = 2,
    },
    items = { { "space-platform-starter-pack", 1 } },
  },
  medic = {
    bonuses = {
      character_health_bonus = 40,
      character_running_speed_modifier = 0.05,
    },
    items = { { "hrt-medkit", 20 }, { "repair-pack", 50 }, { "defender-capsule", 10 } },
  },
  cartographer = {
    bonuses = {
      character_running_speed_modifier = 0.1,
      character_item_pickup_distance_bonus = 2,
    },
    items = { { "radar", 4 }, { "small-lamp", 40 } },
  },
  field_scientist = {
    bonuses = {
      character_crafting_speed_modifier = 0.2,
      character_inventory_slots_bonus = 10,
    },
    items = { { "lab", 2 }, { "automation-science-pack", 100 }, { "logistic-science-pack", 50 } },
  },
  vanguard = {
    bonuses = {
      character_health_bonus = 100,
      character_running_speed_modifier = 0.08,
    },
    items = { { "modular-armor", 1 }, { "piercing-rounds-magazine", 200 }, { "grenade", 40 } },
  },
  prospector = {
    bonuses = {
      character_mining_speed_modifier = 0.25,
      character_resource_reach_distance_bonus = 3,
      character_inventory_slots_bonus = 20,
    },
    items = { { "electric-mining-drill", 8 }, { "steel-plate", 100 } },
  },
  architect = {
    bonuses = {
      character_crafting_speed_modifier = 0.25,
      character_build_distance_bonus = 6,
      character_reach_distance_bonus = 4,
    },
    items = { { "assembling-machine-2", 4 }, { "beacon", 2 }, { "speed-module", 4 } },
  },
  overwatch = {
    bonuses = {
      character_maximum_following_robot_count_bonus = 10,
      character_health_bonus = 50,
    },
    items = { { "destroyer-capsule", 20 }, { "construction-robot", 20 }, { "roboport", 1 } },
  },
}

------------------------------------------------------------------------
-- Prototypes (data stage)
------------------------------------------------------------------------
Balance.weapons = {
  fighter_smg = { cooldown = 8, range = 18, movement_slow_down = 0.5 },
  class_cannon = { cooldown = 45, range = 28, movement_slow_down = 0.6 },
}

Balance.armor_inventory_bonus = {
  fighter = 10,
  miner = 20,
  engineer = 30,
  support = 15,
  explorer = 20,
}

Balance.recipes = {
  armor_time = 15,
  smg_time = 8,
  cannon_time = 12,
}

Balance.technology = {
  class_gear_count = 100,
  class_gear_time = 30,
}

return Balance
