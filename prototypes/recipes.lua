local B = require("scripts.balance")
local Rec = B.recipes
local M = B.medkit

data:extend({
  {
    type = "recipe",
    name = "hrt-armor-fighter",
    enabled = false,
    energy_required = Rec.armor_time,
    ingredients = {
      { type = "item", name = "modular-armor", amount = 1 },
      { type = "item", name = "steel-plate", amount = 40 },
      { type = "item", name = "piercing-rounds-magazine", amount = 50 },
    },
    results = {{ type = "item", name = "hrt-armor-fighter", amount = 1 }},
  },
  {
    type = "recipe",
    name = "hrt-armor-miner",
    enabled = false,
    energy_required = Rec.armor_time,
    ingredients = {
      { type = "item", name = "heavy-armor", amount = 1 },
      { type = "item", name = "steel-plate", amount = 30 },
      { type = "item", name = "electric-mining-drill", amount = 5 },
    },
    results = {{ type = "item", name = "hrt-armor-miner", amount = 1 }},
  },
  {
    type = "recipe",
    name = "hrt-armor-engineer",
    enabled = false,
    energy_required = Rec.armor_time,
    ingredients = {
      { type = "item", name = "modular-armor", amount = 1 },
      { type = "item", name = "steel-plate", amount = 30 },
      { type = "item", name = "electronic-circuit", amount = 50 },
    },
    results = {{ type = "item", name = "hrt-armor-engineer", amount = 1 }},
  },
  {
    type = "recipe",
    name = "hrt-armor-support",
    enabled = false,
    energy_required = Rec.armor_time,
    ingredients = {
      { type = "item", name = "modular-armor", amount = 1 },
      { type = "item", name = "steel-plate", amount = 20 },
      { type = "item", name = "defender-capsule", amount = 10 },
    },
    results = {{ type = "item", name = "hrt-armor-support", amount = 1 }},
  },
  {
    type = "recipe",
    name = "hrt-armor-explorer",
    enabled = false,
    energy_required = Rec.armor_time,
    ingredients = {
      { type = "item", name = "modular-armor", amount = 1 },
      { type = "item", name = "steel-plate", amount = 20 },
      { type = "item", name = "radar", amount = 2 },
      { type = "item", name = "automation-science-pack", amount = 20 },
    },
    results = {{ type = "item", name = "hrt-armor-explorer", amount = 1 }},
  },
  {
    type = "recipe",
    name = "hrt-fighter-smg",
    enabled = false,
    energy_required = Rec.smg_time,
    ingredients = {
      { type = "item", name = "submachine-gun", amount = 1 },
      { type = "item", name = "steel-plate", amount = 20 },
    },
    results = {{ type = "item", name = "hrt-fighter-smg", amount = 1 }},
  },
  {
    type = "recipe",
    name = "hrt-class-cannon",
    enabled = false,
    energy_required = Rec.cannon_time,
    ingredients = {
      { type = "item", name = "rocket-launcher", amount = 1 },
      { type = "item", name = "steel-plate", amount = 30 },
      { type = "item", name = "advanced-circuit", amount = 10 },
    },
    results = {{ type = "item", name = "hrt-class-cannon", amount = 1 }},
  },
  {
    type = "recipe",
    name = "hrt-medkit",
    enabled = true,
    energy_required = M.recipe_time,
    ingredients = {
      { type = "item", name = "repair-pack", amount = 1 },
      { type = "item", name = "raw-fish", amount = 1 },
    },
    results = {{ type = "item", name = "hrt-medkit", amount = M.recipe_output }},
  },
})
