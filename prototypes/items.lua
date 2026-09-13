local B = require("scripts.balance")
local M = B.medkit
local Smg = B.weapons.fighter_smg
local Cannon = B.weapons.class_cannon
local ArmorInv = B.armor_inventory_bonus

local function tinted_armor(name, icon, order, inventory_size_bonus, resistances)
  return {
    type = "armor",
    name = name,
    icon = icon,
    icon_size = 64,
    resistances = resistances or {
      { type = "physical", decrease = 6, percent = 20 },
      { type = "acid", decrease = 0, percent = 20 },
      { type = "explosion", decrease = 10, percent = 20 },
      { type = "fire", decrease = 0, percent = 30 },
    },
    inventory_size_bonus = inventory_size_bonus or 10,
    equipment_grid = "small-equipment-grid",
    subgroup = "armor",
    order = order,
    stack_size = 1,
    infinite = true,
    open_sound = { filename = "__base__/sound/armor-open.ogg", volume = 0.5 },
    close_sound = { filename = "__base__/sound/armor-close.ogg", volume = 0.5 },
  }
end

data:extend({
  {
    type = "gun",
    name = "hrt-fighter-smg",
    icon = "__base__/graphics/icons/submachine-gun.png",
    icon_size = 64,
    subgroup = "gun",
    order = "a[basic-clips]-b[hrt-fighter-smg]",
    attack_parameters = {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = Smg.cooldown,
      movement_slow_down_factor = Smg.movement_slow_down,
      projectile_creation_distance = 1.125,
      range = Smg.range,
      sound = {
        { filename = "__base__/sound/fight/submachine-gunshot-1.ogg", volume = 0.6 },
        { filename = "__base__/sound/fight/submachine-gunshot-2.ogg", volume = 0.6 },
        { filename = "__base__/sound/fight/submachine-gunshot-3.ogg", volume = 0.6 },
      },
    },
    stack_size = 1,
  },
  {
    type = "capsule",
    name = "hrt-medkit",
    icon = "__base__/graphics/icons/repair-pack.png",
    icon_size = 64,
    capsule_action = {
      type = "use-on-self",
      attack_parameters = {
        type = "projectile",
        activation_type = "activate",
        ammo_category = "capsule",
        cooldown = M.cooldown,
        range = 0,
        ammo_type = {
          target_type = "position",
          action = {
            type = "direct",
            action_delivery = {
              type = "instant",
              target_effects = {
                {
                  type = "damage",
                  damage = { amount = M.capsule_heal, type = "physical" },
                },
                {
                  type = "script",
                  effect_id = "hrt-medkit-heal",
                },
              },
            },
          },
        },
      },
    },
    subgroup = "capsule",
    order = "zz[hrt]-medkit",
    stack_size = M.stack_size,
  },
  tinted_armor("hrt-armor-fighter", "__base__/graphics/icons/modular-armor.png", "a[armor]-b[hrt-fighter]", ArmorInv.fighter, {
    { type = "physical", decrease = 8, percent = 30 },
    { type = "explosion", decrease = 12, percent = 30 },
    { type = "acid", decrease = 0, percent = 25 },
    { type = "fire", decrease = 0, percent = 40 },
  }),
  tinted_armor("hrt-armor-miner", "__base__/graphics/icons/heavy-armor.png", "a[armor]-b[hrt-miner]", ArmorInv.miner, {
    { type = "physical", decrease = 4, percent = 15 },
    { type = "explosion", decrease = 5, percent = 15 },
    { type = "acid", decrease = 0, percent = 30 },
    { type = "fire", decrease = 0, percent = 20 },
  }),
  tinted_armor("hrt-armor-engineer", "__base__/graphics/icons/modular-armor.png", "a[armor]-b[hrt-engineer]", ArmorInv.engineer, {
    { type = "physical", decrease = 5, percent = 20 },
    { type = "explosion", decrease = 8, percent = 20 },
    { type = "acid", decrease = 0, percent = 20 },
    { type = "fire", decrease = 0, percent = 30 },
  }),
  tinted_armor("hrt-armor-support", "__base__/graphics/icons/light-armor.png", "a[armor]-b[hrt-support]", ArmorInv.support, {
    { type = "physical", decrease = 4, percent = 20 },
    { type = "explosion", decrease = 6, percent = 25 },
    { type = "acid", decrease = 0, percent = 40 },
    { type = "fire", decrease = 0, percent = 35 },
  }),
  tinted_armor("hrt-armor-explorer", "__base__/graphics/icons/modular-armor.png", "a[armor]-b[hrt-explorer]", ArmorInv.explorer, {
    { type = "physical", decrease = 5, percent = 18 },
    { type = "explosion", decrease = 6, percent = 18 },
    { type = "acid", decrease = 0, percent = 25 },
    { type = "fire", decrease = 0, percent = 25 },
  }),
  {
    type = "gun",
    name = "hrt-class-cannon",
    icon = "__base__/graphics/icons/rocket-launcher.png",
    icon_size = 64,
    subgroup = "gun",
    order = "d[rocket-launcher]-b[hrt]",
    attack_parameters = {
      type = "projectile",
      ammo_category = "rocket",
      cooldown = Cannon.cooldown,
      movement_slow_down_factor = Cannon.movement_slow_down,
      projectile_creation_distance = 0.6,
      range = Cannon.range,
      projectile_center = { -0.17, 0 },
      sound = {{ filename = "__base__/sound/fight/rocket-launcher.ogg", volume = 0.7 }},
    },
    stack_size = 1,
  },
})
