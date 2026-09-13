local Account = require("scripts.account")
local PlayerState = require("scripts.player_state")
local RpgBridge = require("scripts.rpg_bridge")
local B = require("scripts.balance")

local Roadmap = {}
local Gui -- injected from control.lua

function Roadmap.set_gui(mod)
  Gui = mod
end

Roadmap.trees = require("scripts.roadmap_trees")
local R = B.roadmap

local PHASES = { "early", "mid", "late" }

local function current_quest(st)
  if not st.class then return nil end
  local tree = Roadmap.trees[st.class]
  if not tree then return nil end
  return tree[st.roadmap_index]
end

function Roadmap.get_quest(player)
  return current_quest(PlayerState.get(player))
end

function Roadmap.phase_of_index(class_id, index)
  local tree = Roadmap.trees[class_id]
  if not tree or not tree[index] then return nil end
  return tree[index].phase
end

function Roadmap.quests_in_phase(class_id, phase)
  local list = {}
  local tree = Roadmap.trees[class_id]
  if not tree then return list end
  for i, q in ipairs(tree) do
    if q.phase == phase then
      list[#list + 1] = { index = i, quest = q }
    end
  end
  return list
end

local function complete_quest(player, st, quest)
  st.quest_progress[quest.id] = st.quest_progress[quest.id] or {}
  if st.quest_progress[quest.id].done then return end
  st.quest_progress[quest.id].done = true
  if quest.reward_item and prototypes.item[quest.reward_item[1]] then
    player.insert{ name = quest.reward_item[1], count = quest.reward_item[2] }
  end
  local xp = quest.xp or R.default_quest_xp
  RpgBridge.give_xp(player.name, xp)
  Account.add_xp(player.name, math.floor(xp * R.account_xp_from_quest))
  player.print({ "hrt-rpg.quest-complete", quest.desc })
  player.play_sound{ path = "utility/achievement_unlocked" }
  if quest.reward_unlock_subclass and Gui then
    Gui.open_subclass(player, quest.reward_unlock_subclass)
  end
  st.roadmap_index = st.roadmap_index + 1
  if not Roadmap.trees[st.class][st.roadmap_index] then
    Account.add_xp(player.name, R.roadmap_done_account_xp)
    player.print({ "hrt-rpg.roadmap-done" })
  end
  if Gui then
    Gui.refresh_top(player)
  end
end

local function bump(player, amount)
  local st = PlayerState.get(player)
  local quest = current_quest(st)
  if not quest then return end
  if quest.type == "research" then return end
  local prog = st.quest_progress[quest.id] or { count = 0 }
  if prog.done then return end
  prog.count = (prog.count or 0) + (amount or 1)
  st.quest_progress[quest.id] = prog
  if quest.target and prog.count >= quest.target then
    complete_quest(player, st, quest)
  end
end

local function matches_build(quest, entity_name)
  return quest.entity and entity_name == quest.entity
end

local function on_built(player, entity)
  if not player or not entity or not entity.valid then return end
  local st = PlayerState.get(player)
  local quest = current_quest(st)
  if not quest then return end
  if quest.type == "build" or quest.type == "place" then
    if matches_build(quest, entity.name) then
      bump(player, 1)
    end
  end
  if quest.type == "deliver" and (entity.name == "steel-chest" or entity.name == "iron-chest" or entity.type == "container") then
    st.supply_chests = st.supply_chests or {}
    st.supply_chests[#st.supply_chests + 1] = { x = entity.position.x, y = entity.position.y, surface = entity.surface.index }
  end
end

script.on_event(defines.events.on_player_crafted_item, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local st = PlayerState.get(player)
  local quest = current_quest(st)
  if not quest or quest.type ~= "craft" then return end
  if quest.item and event.item_stack and event.item_stack.valid_for_read and event.item_stack.name == quest.item then
    bump(player, event.item_stack.count)
  end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local st = PlayerState.get(player)
  local quest = current_quest(st)
  if not quest or quest.type ~= "mine" then return end
  local ent = event.entity
  if quest.ore and ent and ent.name == quest.ore then
    local amt = 1
    if event.buffer and event.buffer.get_item_count then
      amt = math.max(1, event.buffer.get_item_count(quest.ore))
    end
    bump(player, amt)
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  local player = game.get_player(event.player_index)
  on_built(player, event.entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  local ent = event.entity
  if not ent or not ent.valid then return end
  local force = ent.force
  for _, player in pairs(game.connected_players) do
    if player.force == force then
      local st = PlayerState.get(player)
      local quest = current_quest(st)
      if quest and (quest.type == "build" or quest.type == "place") and matches_build(quest, ent.name) then
        bump(player, 1)
        return
      end
    end
  end
end)

script.on_event(defines.events.on_entity_died, function(event)
  local cause = event.cause
  if not cause or not cause.valid then return end
  local player = cause.type == "character" and cause.player or nil
  if not player and cause.type == "car" and cause.get_driver then
    local driver = cause.get_driver()
    if driver and driver.is_player then player = driver end
    if driver and driver.type == "character" then player = driver.player end
  end
  if not player then return end
  local st = PlayerState.get(player)
  local quest = current_quest(st)
  if not quest or quest.type ~= "kill" then return end
  if not (event.entity and event.entity.type == "unit") then return end
  if quest.unit and event.entity.name ~= quest.unit then return end
  bump(player, 1)
end)

script.on_event(defines.events.on_research_finished, function(event)
  for _, player in pairs(game.connected_players) do
    local st = PlayerState.get(player)
    local quest = current_quest(st)
    if quest and quest.type == "research" and quest.tech == event.research.name then
      if player.force == event.research.force then
        complete_quest(player, st, quest)
      end
    end
  end
end)

script.on_event(defines.events.on_player_changed_position, function(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character then return end
  local st = PlayerState.get(player)
  local quest = current_quest(st)
  if not quest or quest.type ~= "distance" then return end
  local pos = player.position
  if st.last_pos then
    local dx = pos.x - st.last_pos.x
    local dy = pos.y - st.last_pos.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > 0 and dist < R.distance_step_max then
      bump(player, dist)
    end
  end
  st.last_pos = { x = pos.x, y = pos.y }
end)

local function count_charted_chunks(force, surface)
  local count = 0
  for chunk in surface.get_chunks() do
    if force.is_chunk_charted(surface, { x = chunk.x, y = chunk.y }) then
      count = count + 1
    end
  end
  return count
end

local function poll_deliver(player, st, quest)
  if not quest.item or not quest.target then return end
  local total = 0
  local surface = game.get_surface(1)
  if not surface then return end
  -- Prefer tagged supply chests; also count nearby steel/iron chests
  local chests = surface.find_entities_filtered{
    position = player.position,
    radius = R.deliver_scan_radius,
    type = "container",
  }
  for _, chest in pairs(chests) do
    if chest.valid and chest.get_inventory then
      local inv = chest.get_inventory(defines.inventory.chest)
      if inv then
        total = total + inv.get_item_count(quest.item)
      end
    end
  end
  local prog = st.quest_progress[quest.id] or { count = 0 }
  if total > (prog.count or 0) then
    prog.count = total
    st.quest_progress[quest.id] = prog
    if prog.count >= quest.target then
      complete_quest(player, st, quest)
    end
  end
end

local function poll_chart(player, st, quest)
  local surface = player.surface
  if not surface then return end
  local count = count_charted_chunks(player.force, surface)
  local prog = st.quest_progress[quest.id] or { count = 0 }
  if count > (prog.count or 0) then
    prog.count = count
    st.quest_progress[quest.id] = prog
    if quest.target and prog.count >= quest.target then
      complete_quest(player, st, quest)
    end
  end
end

function Roadmap.tick()
  local do_chart = (game.tick % R.chart_poll_mod) < R.chart_poll_window
  for _, player in pairs(game.connected_players) do
    local st = PlayerState.get(player)
    local quest = current_quest(st)
    if not quest then goto continue end
    if quest.type == "deliver" then
      poll_deliver(player, st, quest)
    elseif quest.type == "chart" and do_chart then
      poll_chart(player, st, quest)
    elseif quest.type == "research" and quest.tech then
      if player.force.technologies[quest.tech] and player.force.technologies[quest.tech].researched then
        complete_quest(player, st, quest)
      end
    end
    ::continue::
  end
end

function Roadmap.progress_text(player)
  local st = PlayerState.get(player)
  local quest = current_quest(st)
  if not st.class then return { "hrt-rpg.no-class" } end
  if not quest then return { "hrt-rpg.roadmap-done" } end
  local prog = st.quest_progress[quest.id] or { count = 0 }
  local phase_key = "hrt-rpg.phase-" .. (quest.phase or "early")
  if quest.type == "research" then
    return { "hrt-rpg.quest-line-phase", { phase_key }, quest.desc, 0, 1 }
  end
  local count = math.floor(prog.count or 0)
  local target = quest.target or 1
  if quest.type == "distance" then
    count = math.floor(count)
    target = math.floor(target)
  end
  return { "hrt-rpg.quest-line-phase", { phase_key }, quest.desc, count, target }
end

Roadmap.PHASES = PHASES
Roadmap.complete_quest = complete_quest

return Roadmap
