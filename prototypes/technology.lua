local B = require("scripts.balance")
local T = B.technology

data:extend({
  {
    type = "technology",
    name = "hrt-class-gear",
    icon = "__base__/graphics/technology/power-armor.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "hrt-armor-fighter" },
      { type = "unlock-recipe", recipe = "hrt-armor-miner" },
      { type = "unlock-recipe", recipe = "hrt-armor-engineer" },
      { type = "unlock-recipe", recipe = "hrt-armor-support" },
      { type = "unlock-recipe", recipe = "hrt-armor-explorer" },
      { type = "unlock-recipe", recipe = "hrt-fighter-smg" },
      { type = "unlock-recipe", recipe = "hrt-class-cannon" },
    },
    prerequisites = { "modular-armor" },
    unit = {
      count = T.class_gear_count,
      ingredients = {
        { "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
      },
      time = T.class_gear_time,
    },
    order = "a-hrt-gear",
  },
})
