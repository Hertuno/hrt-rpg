local Account = require("scripts.account")
local PlayerState = require("scripts.player_state")
local RpgBridge = require("scripts.rpg_bridge")
local B = require("scripts.balance")

local Classes = {}
local Subclass -- injected from control.lua (avoid runtime require + circular load)

function Classes.set_subclass(mod)
  Subclass = mod
end

Classes.defs = {
  fighter = {
    title = { "hrt-rpg.class-fighter" },
    bob_hint = "fighter",
    bonuses = B.classes.fighter.bonuses,
    damage_bonus = B.classes.fighter.damage_bonus,
    kit = B.classes.fighter.kit,
    mid_armor = "hrt-armor-fighter",
  },
  miner = {
    title = { "hrt-rpg.class-miner" },
    bob_hint = "builder",
    bonuses = B.classes.miner.bonuses,
    kit = B.classes.miner.kit,
    mid_armor = "hrt-armor-miner",
  },
  engineer = {
    title = { "hrt-rpg.class-engineer" },
    bob_hint = "crafter",
    bonuses = B.classes.engineer.bonuses,
    kit = B.classes.engineer.kit,
    mid_armor = "hrt-armor-engineer",
  },
  support = {
    title = { "hrt-rpg.class-support" },
    bob_hint = nil,
    bonuses = B.classes.support.bonuses,
    kit = B.classes.support.kit,
    mid_armor = "hrt-armor-support",
  },
  explorer = {
    title = { "hrt-rpg.class-explorer" },
    bob_hint = nil,
    bonuses = B.classes.explorer.bonuses,
    kit = B.classes.explorer.kit,
    mid_armor = "hrt-armor-explorer",
  },
}

local BONUS_KEYS = {
  "character_health_bonus",
  "character_mining_speed_modifier",
  "character_crafting_speed_modifier",
  "character_running_speed_modifier",
  "character_inventory_slots_bonus",
  "character_build_distance_bonus",
  "character_reach_distance_bonus",
  "character_resource_reach_distance_bonus",
  "character_item_pickup_distance_bonus",
  "character_loot_pickup_distance_bonus",
  "character_maximum_following_robot_count_bonus",
}

local function has_character(player)
  return player and player.valid and player.character and player.character.valid
end

local function clear_character_bonuses(player)
  if not has_character(player) then return end
  for _, k in ipairs(BONUS_KEYS) do
    pcall(function()
      player[k] = 0
    end)
  end
end

function Classes.reapply_bonuses(player)
  local st = PlayerState.get(player)
  if not st.class then return end
  if not has_character(player) then
    st.bonuses_pending = true
    return
  end
  local def = Classes.defs[st.class]
  if not def then return end
  clear_character_bonuses(player)
  for k, v in pairs(def.bonuses or {}) do
    pcall(function()
      player[k] = (player[k] or 0) + v
    end)
  end
  if Subclass then
    if st.subclass_common then
      Subclass.apply(player, st.subclass_common)
    end
    if st.subclass_spec then
      Subclass.apply(player, st.subclass_spec)
    end
  end
  Account.apply_paragons(player)
  st.bonuses_pending = false
end

--- Call when a body may have appeared (bobclasses / respawn).
function Classes.try_pending_bonuses(player)
  local st = PlayerState.get(player)
  if st.class and st.bonuses_pending and has_character(player) then
    Classes.reapply_bonuses(player)
  end
end

function Classes.give_kit(player, class_id)
  local def = Classes.defs[class_id]
  if not def then return end
  local inv = player.get_main_inventory and player.get_main_inventory()
  if not inv then return end
  for _, entry in ipairs(def.kit) do
    local name, count = entry[1], entry[2]
    if prototypes.item[name] then
      player.insert{ name = name, count = count }
    end
  end
end

function Classes.select(player, class_id)
  local def = Classes.defs[class_id]
  if not def then return false end
  local st = PlayerState.get(player)
  if st.class and st.body_locked then
    player.print({ "hrt-rpg.class-locked" })
    return false
  end
  if not Account.class_unlocked(player.name, class_id) then
    local need = Account.unlock_requirement(class_id) or "?"
    player.print({ "hrt-rpg.class-locked-level", def.title, need })
    return false
  end
  st.class = class_id
  st.body_locked = true
  st.roadmap_index = 1
  st.quest_progress = {}
  st.subclass_common = nil
  st.subclass_spec = nil
  st.roadmap_v2 = true
  st.distance_accum = 0
  st.supply_chests = {}
  if not st.starter_given then
    Classes.give_kit(player, class_id)
    st.starter_given = true
  end
  Classes.reapply_bonuses(player)
  RpgBridge.give_xp(player.name, B.account.class_select_rpg_xp)
  Account.add_xp(player.name, B.account.class_select_account_xp)
  player.print({ "hrt-rpg.class-selected", def.title })
  if not has_character(player) then
    player.print({ "hrt-rpg.class-bonuses-pending" })
  end
  pcall(function()
    player.play_sound{ path = "utility/new_objective" }
  end)
  return true
end

function Classes.map_from_bob(character_name)
  if not character_name then return nil end
  local n = string.lower(character_name)
  if n:find("fight", 1, true) then return "fighter" end
  if n:find("build", 1, true) then return "miner" end
  if n:find("craft", 1, true) then return "engineer" end
  return nil
end

return Classes
