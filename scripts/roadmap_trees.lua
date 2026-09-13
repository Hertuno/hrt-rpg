-- Quest trees: 3 phases × 9 quests per class.
-- Types: kill, build, craft, mine, research, distance, deliver, chart
-- reward_unlock_subclass: "common" | "specialized"

local function q(id, phase, desc_key, typ, opts)
  local t = {
    id = id,
    phase = phase,
    desc = { "hrt-rpg." .. desc_key },
    type = typ,
    xp = opts.xp or 80,
  }
  for k, v in pairs(opts) do
    if k ~= "xp" then t[k] = v end
  end
  return t
end

local Trees = {}

Trees.fighter = {
  -- Early
  q("f-e1", "early", "q-f-e1", "kill", { target = 15, reward_item = { "firearm-magazine", 50 }, xp = 60 }),
  q("f-e2", "early", "q-f-e2", "build", { entity = "stone-wall", target = 40, reward_item = { "stone-brick", 50 }, xp = 70 }),
  q("f-e3", "early", "q-f-e3", "build", { entity = "gun-turret", target = 4, reward_item = { "firearm-magazine", 100 }, xp = 80 }),
  q("f-e4", "early", "q-f-e4", "kill", { target = 40, reward_item = { "piercing-rounds-magazine", 50 }, xp = 90 }),
  q("f-e5", "early", "q-f-e5", "craft", { item = "grenade", target = 20, reward_item = { "grenade", 20 }, xp = 90 }),
  q("f-e6", "early", "q-f-e6", "build", { entity = "gun-turret", target = 10, reward_item = { "steel-plate", 30 }, xp = 100 }),
  q("f-e7", "early", "q-f-e7", "research", { tech = "military", reward_item = { "submachine-gun", 1 }, xp = 110 }),
  q("f-e8", "early", "q-f-e8", "kill", { target = 80, reward_item = { "heavy-armor", 1 }, xp = 120 }),
  q("f-e9", "early", "q-f-e9", "kill", { target = 120, reward_unlock_subclass = "common", xp = 150 }),
  -- Mid
  q("f-m1", "mid", "q-f-m1", "craft", { item = "piercing-rounds-magazine", target = 100, reward_item = { "piercing-rounds-magazine", 100 }, xp = 100 }),
  q("f-m2", "mid", "q-f-m2", "build", { entity = "gun-turret", target = 20, reward_item = { "land-mine", 20 }, xp = 110 }),
  q("f-m3", "mid", "q-f-m3", "research", { tech = "military-2", reward_item = { "combat-shotgun", 1 }, xp = 120 }),
  q("f-m4", "mid", "q-f-m4", "kill", { target = 150, unit = "medium-biter", reward_item = { "grenade", 40 }, xp = 120 }),
  q("f-m5", "mid", "q-f-m5", "build", { entity = "flamethrower-turret", target = 2, reward_item = { "flamethrower-ammo", 50 }, xp = 130 }),
  q("f-m6", "mid", "q-f-m6", "craft", { item = "military-science-pack", target = 50, reward_item = { "military-science-pack", 50 }, xp = 130 }),
  q("f-m7", "mid", "q-f-m7", "distance", { target = 3000, reward_item = { "car", 1 }, xp = 140 }),
  q("f-m8", "mid", "q-f-m8", "kill", { target = 200, reward_item = { "modular-armor", 1 }, xp = 150 }),
  q("f-m9", "mid", "q-f-m9", "research", { tech = "tank", reward_unlock_subclass = "specialized", xp = 180 }),
  -- Late
  q("f-l1", "late", "q-f-l1", "kill", { target = 50, unit = "big-biter", reward_item = { "explosive-rocket", 20 }, xp = 150 }),
  q("f-l2", "late", "q-f-l2", "build", { entity = "laser-turret", target = 10, reward_item = { "laser-turret", 5 }, xp = 160 }),
  q("f-l3", "late", "q-f-l3", "craft", { item = "rocket", target = 40, reward_item = { "rocket-launcher", 1 }, xp = 160 }),
  q("f-l4", "late", "q-f-l4", "research", { tech = "military-3", reward_item = { "uranium-rounds-magazine", 50 }, xp = 170 }),
  q("f-l5", "late", "q-f-l5", "kill", { target = 20, unit = "behemoth-biter", reward_item = { "power-armor", 1 }, xp = 180 }),
  q("f-l6", "late", "q-f-l6", "build", { entity = "artillery-turret", target = 1, reward_item = { "artillery-shell", 10 }, xp = 190 }),
  q("f-l7", "late", "q-f-l7", "deliver", { item = "piercing-rounds-magazine", target = 200, reward_item = { "destroyer-capsule", 10 }, xp = 190 }),
  q("f-l8", "late", "q-f-l8", "kill", { target = 400, reward_item = { "atomic-bomb", 1 }, xp = 200 }),
  q("f-l9", "late", "q-f-l9", "research", { tech = "atomic-bomb", reward_item = { "atomic-bomb", 1 }, xp = 250 }),
}

Trees.miner = {
  q("m-e1", "early", "q-m-e1", "mine", { ore = "iron-ore", target = 300, reward_item = { "iron-plate", 50 }, xp = 60 }),
  q("m-e2", "early", "q-m-e2", "mine", { ore = "copper-ore", target = 200, reward_item = { "copper-plate", 50 }, xp = 70 }),
  q("m-e3", "early", "q-m-e3", "build", { entity = "burner-mining-drill", target = 4, reward_item = { "coal", 100 }, xp = 80 }),
  q("m-e4", "early", "q-m-e4", "build", { entity = "stone-furnace", target = 8, reward_item = { "stone", 50 }, xp = 80 }),
  q("m-e5", "early", "q-m-e5", "build", { entity = "electric-mining-drill", target = 4, reward_item = { "transport-belt", 100 }, xp = 90 }),
  q("m-e6", "early", "q-m-e6", "mine", { ore = "coal", target = 400, reward_item = { "steel-plate", 20 }, xp = 90 }),
  q("m-e7", "early", "q-m-e7", "craft", { item = "iron-plate", target = 200, reward_item = { "iron-gear-wheel", 50 }, xp = 100 }),
  q("m-e8", "early", "q-m-e8", "research", { tech = "steel-processing", reward_item = { "steel-plate", 50 }, xp = 110 }),
  q("m-e9", "early", "q-m-e9", "mine", { ore = "iron-ore", target = 1000, reward_unlock_subclass = "common", xp = 150 }),
  q("m-m1", "mid", "q-m-m1", "build", { entity = "electric-mining-drill", target = 16, reward_item = { "electric-mining-drill", 4 }, xp = 100 }),
  q("m-m2", "mid", "q-m-m2", "craft", { item = "steel-plate", target = 100, reward_item = { "steel-chest", 5 }, xp = 110 }),
  q("m-m3", "mid", "q-m-m3", "research", { tech = "oil-processing", reward_item = { "pumpjack", 2 }, xp = 120 }),
  q("m-m4", "mid", "q-m-m4", "build", { entity = "pumpjack", target = 2, reward_item = { "pipe", 50 }, xp = 120 }),
  q("m-m5", "mid", "q-m-m5", "build", { entity = "oil-refinery", target = 1, reward_item = { "chemical-plant", 2 }, xp = 130 }),
  q("m-m6", "mid", "q-m-m6", "mine", { ore = "stone", target = 800, reward_item = { "concrete", 100 }, xp = 130 }),
  q("m-m7", "mid", "q-m-m7", "craft", { item = "plastic-bar", target = 50, reward_item = { "plastic-bar", 50 }, xp = 140 }),
  q("m-m8", "mid", "q-m-m8", "build", { entity = "train-stop", target = 1, reward_item = { "rail", 50 }, xp = 150 }),
  q("m-m9", "mid", "q-m-m9", "research", { tech = "railway", reward_unlock_subclass = "specialized", xp = 180 }),
  q("m-l1", "late", "q-m-l1", "build", { entity = "electric-mining-drill", target = 40, reward_item = { "productivity-module", 4 }, xp = 150 }),
  q("m-l2", "late", "q-m-l2", "craft", { item = "productivity-module", target = 10, reward_item = { "productivity-module", 10 }, xp = 160 }),
  q("m-l3", "late", "q-m-l3", "mine", { ore = "iron-ore", target = 5000, reward_item = { "steel-plate", 200 }, xp = 160 }),
  q("m-l4", "late", "q-m-l4", "research", { tech = "mining-productivity-1", reward_item = { "electric-mining-drill", 10 }, xp = 170 }),
  q("m-l5", "late", "q-m-l5", "build", { entity = "electric-furnace", target = 12, reward_item = { "electric-furnace", 4 }, xp = 180 }),
  q("m-l6", "late", "q-m-l6", "deliver", { item = "iron-plate", target = 500, reward_item = { "logistic-chest-passive-provider", 4 }, xp = 180 }),
  q("m-l7", "late", "q-m-l7", "mine", { ore = "uranium-ore", target = 200, reward_item = { "uranium-238", 20 }, xp = 190 }),
  q("m-l8", "late", "q-m-l8", "build", { entity = "centrifuge", target = 1, reward_item = { "uranium-fuel-cell", 5 }, xp = 200 }),
  q("m-l9", "late", "q-m-l9", "research", { tech = "kovarex-enrichment-process", reward_item = { "uranium-235", 5 }, xp = 250 }),
}

Trees.engineer = {
  q("e-e1", "early", "q-e-e1", "craft", { item = "iron-gear-wheel", target = 50, reward_item = { "iron-gear-wheel", 50 }, xp = 60 }),
  q("e-e2", "early", "q-e-e2", "craft", { item = "electronic-circuit", target = 40, reward_item = { "electronic-circuit", 40 }, xp = 70 }),
  q("e-e3", "early", "q-e-e3", "build", { entity = "assembling-machine-1", target = 3, reward_item = { "inserter", 20 }, xp = 80 }),
  q("e-e4", "early", "q-e-e4", "build", { entity = "transport-belt", target = 100, reward_item = { "underground-belt", 20 }, xp = 80 }),
  q("e-e5", "early", "q-e-e5", "research", { tech = "automation", reward_item = { "assembling-machine-1", 2 }, xp = 90 }),
  q("e-e6", "early", "q-e-e6", "craft", { item = "automation-science-pack", target = 50, reward_item = { "lab", 1 }, xp = 90 }),
  q("e-e7", "early", "q-e-e7", "build", { entity = "lab", target = 2, reward_item = { "automation-science-pack", 50 }, xp = 100 }),
  q("e-e8", "early", "q-e-e8", "research", { tech = "logistic-science-pack", reward_item = { "logistic-science-pack", 50 }, xp = 110 }),
  q("e-e9", "early", "q-e-e9", "research", { tech = "automation-2", reward_unlock_subclass = "common", xp = 150 }),
  q("e-m1", "mid", "q-e-m1", "build", { entity = "assembling-machine-2", target = 8, reward_item = { "fast-inserter", 20 }, xp = 100 }),
  q("e-m2", "mid", "q-e-m2", "research", { tech = "oil-processing", reward_item = { "chemical-plant", 2 }, xp = 110 }),
  q("e-m3", "mid", "q-e-m3", "build", { entity = "chemical-plant", target = 2, reward_item = { "pipe", 40 }, xp = 120 }),
  q("e-m4", "mid", "q-e-m4", "craft", { item = "advanced-circuit", target = 50, reward_item = { "advanced-circuit", 50 }, xp = 120 }),
  q("e-m5", "mid", "q-e-m5", "craft", { item = "chemical-science-pack", target = 50, reward_item = { "chemical-science-pack", 50 }, xp = 130 }),
  q("e-m6", "mid", "q-e-m6", "build", { entity = "roboport", target = 1, reward_item = { "construction-robot", 10 }, xp = 130 }),
  q("e-m7", "mid", "q-e-m7", "craft", { item = "construction-robot", target = 20, reward_item = { "logistic-robot", 10 }, xp = 140 }),
  q("e-m8", "mid", "q-e-m8", "research", { tech = "construction-robotics", reward_item = { "roboport", 1 }, xp = 150 }),
  q("e-m9", "mid", "q-e-m9", "research", { tech = "logistic-robotics", reward_unlock_subclass = "specialized", xp = 180 }),
  q("e-l1", "late", "q-e-l1", "build", { entity = "assembling-machine-3", target = 10, reward_item = { "speed-module", 4 }, xp = 150 }),
  q("e-l2", "late", "q-e-l2", "build", { entity = "beacon", target = 4, reward_item = { "speed-module", 8 }, xp = 160 }),
  q("e-l3", "late", "q-e-l3", "craft", { item = "speed-module", target = 20, reward_item = { "productivity-module", 10 }, xp = 160 }),
  q("e-l4", "late", "q-e-l4", "craft", { item = "production-science-pack", target = 50, reward_item = { "production-science-pack", 50 }, xp = 170 }),
  q("e-l5", "late", "q-e-l5", "research", { tech = "effect-transmission", reward_item = { "beacon", 4 }, xp = 180 }),
  q("e-l6", "late", "q-e-l6", "build", { entity = "express-transport-belt", target = 200, reward_item = { "express-underground-belt", 40 }, xp = 180 }),
  q("e-l7", "late", "q-e-l7", "deliver", { item = "electronic-circuit", target = 400, reward_item = { "bulk-inserter", 20 }, xp = 190 }),
  q("e-l8", "late", "q-e-l8", "craft", { item = "utility-science-pack", target = 50, reward_item = { "utility-science-pack", 50 }, xp = 200 }),
  q("e-l9", "late", "q-e-l9", "research", { tech = "rocket-silo", reward_item = { "rocket-part", 10 }, xp = 250 }),
}

Trees.support = {
  q("s-e1", "early", "q-s-e1", "craft", { item = "repair-pack", target = 20, reward_item = { "repair-pack", 20 }, xp = 60 }),
  q("s-e2", "early", "q-s-e2", "craft", { item = "hrt-medkit", target = 10, reward_item = { "hrt-medkit", 10 }, xp = 70 }),
  q("s-e3", "early", "q-s-e3", "craft", { item = "defender-capsule", target = 10, reward_item = { "defender-capsule", 10 }, xp = 80 }),
  q("s-e4", "early", "q-s-e4", "build", { entity = "stone-wall", target = 50, reward_item = { "gate", 4 }, xp = 80 }),
  q("s-e5", "early", "q-s-e5", "build", { entity = "gun-turret", target = 4, reward_item = { "firearm-magazine", 100 }, xp = 90 }),
  q("s-e6", "early", "q-s-e6", "research", { tech = "military", reward_item = { "defender-capsule", 20 }, xp = 90 }),
  q("s-e7", "early", "q-s-e7", "craft", { item = "repair-pack", target = 60, reward_item = { "hrt-medkit", 15 }, xp = 100 }),
  q("s-e8", "early", "q-s-e8", "build", { entity = "radar", target = 1, reward_item = { "small-lamp", 20 }, xp = 110 }),
  q("s-e9", "early", "q-s-e9", "craft", { item = "defender-capsule", target = 30, reward_unlock_subclass = "common", xp = 150 }),
  q("s-m1", "mid", "q-s-m1", "build", { entity = "roboport", target = 1, reward_item = { "construction-robot", 15 }, xp = 100 }),
  q("s-m2", "mid", "q-s-m2", "craft", { item = "construction-robot", target = 25, reward_item = { "logistic-robot", 10 }, xp = 110 }),
  q("s-m3", "mid", "q-s-m3", "research", { tech = "construction-robotics", reward_item = { "roboport", 1 }, xp = 120 }),
  q("s-m4", "mid", "q-s-m4", "build", { entity = "roboport", target = 3, reward_item = { "accumulator", 10 }, xp = 120 }),
  q("s-m5", "mid", "q-s-m5", "deliver", { item = "firearm-magazine", target = 100, reward_item = { "piercing-rounds-magazine", 100 }, xp = 130 }),
  q("s-m6", "mid", "q-s-m6", "craft", { item = "distractor-capsule", target = 20, reward_item = { "distractor-capsule", 20 }, xp = 130 }),
  q("s-m7", "mid", "q-s-m7", "build", { entity = "laser-turret", target = 5, reward_item = { "laser-turret", 5 }, xp = 140 }),
  q("s-m8", "mid", "q-s-m8", "craft", { item = "repair-pack", target = 150, reward_item = { "hrt-medkit", 30 }, xp = 150 }),
  q("s-m9", "mid", "q-s-m9", "research", { tech = "follower-robot-count-1", reward_unlock_subclass = "specialized", xp = 180 }),
  q("s-l1", "late", "q-s-l1", "craft", { item = "destroyer-capsule", target = 30, reward_item = { "destroyer-capsule", 30 }, xp = 150 }),
  q("s-l2", "late", "q-s-l2", "build", { entity = "roboport", target = 6, reward_item = { "construction-robot", 40 }, xp = 160 }),
  q("s-l3", "late", "q-s-l3", "deliver", { item = "repair-pack", target = 200, reward_item = { "power-armor", 1 }, xp = 160 }),
  q("s-l4", "late", "q-s-l4", "research", { tech = "destroyer", reward_item = { "destroyer-capsule", 20 }, xp = 170 }),
  q("s-l5", "late", "q-s-l5", "craft", { item = "hrt-medkit", target = 50, reward_item = { "hrt-medkit", 50 }, xp = 180 }),
  q("s-l6", "late", "q-s-l6", "build", { entity = "artillery-turret", target = 1, reward_item = { "artillery-shell", 5 }, xp = 180 }),
  q("s-l7", "late", "q-s-l7", "deliver", { item = "piercing-rounds-magazine", target = 300, reward_item = { "uranium-rounds-magazine", 100 }, xp = 190 }),
  q("s-l8", "late", "q-s-l8", "craft", { item = "construction-robot", target = 80, reward_item = { "logistic-robot", 40 }, xp = 200 }),
  q("s-l9", "late", "q-s-l9", "research", { tech = "follower-robot-count-5", reward_item = { "destroyer-capsule", 50 }, xp = 250 }),
}

Trees.explorer = {
  q("x-e1", "early", "q-x-e1", "build", { entity = "radar", target = 1, reward_item = { "automation-science-pack", 30 }, xp = 60 }),
  q("x-e2", "early", "q-x-e2", "build", { entity = "lab", target = 1, reward_item = { "lab", 1 }, xp = 70 }),
  q("x-e3", "early", "q-x-e3", "craft", { item = "automation-science-pack", target = 50, reward_item = { "automation-science-pack", 50 }, xp = 80 }),
  q("x-e4", "early", "q-x-e4", "build", { entity = "radar", target = 3, reward_item = { "small-lamp", 30 }, xp = 80 }),
  q("x-e5", "early", "q-x-e5", "chart", { target = 40, reward_item = { "radar", 2 }, xp = 90 }),
  q("x-e6", "early", "q-x-e6", "research", { tech = "radar", reward_item = { "radar", 2 }, xp = 90 }),
  q("x-e7", "early", "q-x-e7", "craft", { item = "logistic-science-pack", target = 50, reward_item = { "logistic-science-pack", 50 }, xp = 100 }),
  q("x-e8", "early", "q-x-e8", "distance", { target = 2000, reward_item = { "car", 1 }, xp = 110 }),
  q("x-e9", "early", "q-x-e9", "build", { entity = "lab", target = 4, reward_unlock_subclass = "common", xp = 150 }),
  q("x-m1", "mid", "q-x-m1", "distance", { target = 8000, reward_item = { "exoskeleton-equipment", 1 }, xp = 100 }),
  q("x-m2", "mid", "q-x-m2", "build", { entity = "radar", target = 8, reward_item = { "radar", 4 }, xp = 110 }),
  q("x-m3", "mid", "q-x-m3", "chart", { target = 120, reward_item = { "cliff-explosives", 10 }, xp = 120 }),
  q("x-m4", "mid", "q-x-m4", "craft", { item = "chemical-science-pack", target = 50, reward_item = { "chemical-science-pack", 50 }, xp = 120 }),
  q("x-m5", "mid", "q-x-m5", "research", { tech = "military-science-pack", reward_item = { "military-science-pack", 50 }, xp = 130 }),
  q("x-m6", "mid", "q-x-m6", "build", { entity = "car", target = 1, reward_item = { "firearm-magazine", 100 }, xp = 130 }),
  q("x-m7", "mid", "q-x-m7", "craft", { item = "military-science-pack", target = 50, reward_item = { "grenade", 30 }, xp = 140 }),
  q("x-m8", "mid", "q-x-m8", "chart", { target = 200, reward_item = { "modular-armor", 1 }, xp = 150 }),
  q("x-m9", "mid", "q-x-m9", "research", { tech = "automobilism", reward_unlock_subclass = "specialized", xp = 180 }),
  q("x-l1", "late", "q-x-l1", "chart", { target = 400, reward_item = { "artillery-wagon", 1 }, xp = 150 }),
  q("x-l2", "late", "q-x-l2", "build", { entity = "radar", target = 16, reward_item = { "radar", 8 }, xp = 160 }),
  q("x-l3", "late", "q-x-l3", "distance", { target = 20000, reward_item = { "tank", 1 }, xp = 160 }),
  q("x-l4", "late", "q-x-l4", "craft", { item = "utility-science-pack", target = 50, reward_item = { "utility-science-pack", 50 }, xp = 170 }),
  q("x-l5", "late", "q-x-l5", "research", { tech = "artillery", reward_item = { "artillery-targeting-remote", 1 }, xp = 180 }),
  q("x-l6", "late", "q-x-l6", "build", { entity = "artillery-turret", target = 1, reward_item = { "artillery-shell", 10 }, xp = 180 }),
  q("x-l7", "late", "q-x-l7", "deliver", { item = "automation-science-pack", target = 200, reward_item = { "lab", 4 }, xp = 190 }),
  q("x-l8", "late", "q-x-l8", "chart", { target = 600, reward_item = { "power-armor", 1 }, xp = 200 }),
  q("x-l9", "late", "q-x-l9", "research", { tech = "space-science-pack", reward_item = { "space-science-pack", 100 }, xp = 250 }),
}

return Trees
