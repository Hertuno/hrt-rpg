local Account = require("scripts.account")
local Classes = require("scripts.classes")
local Roadmap = require("scripts.roadmap")
local Subclass = require("scripts.subclass")
local Events = require("scripts.events")
local Gui = require("scripts.gui")
local PlayerState = require("scripts.player_state")
local RpgBridge = require("scripts.rpg_bridge")
local B = require("scripts.balance")

-- Wire circular deps without runtime require()
Classes.set_subclass(Subclass)
Roadmap.set_gui(Gui)

local function ensure_storage()
  storage.players = storage.players or {}
  storage.accounts = storage.accounts or {}
  storage.events = storage.events or { next_tick = 0, active = nil }
  storage.settings = storage.settings or { body_lock = true }
end

script.on_init(function()
  ensure_storage()
  Events.schedule_next()
end)

script.on_load(function()
  -- no metatables needed
end)

script.on_configuration_changed(function()
  ensure_storage()
  for _, player in pairs(game.players) do
    PlayerState.ensure(player) -- migrates subclass + roadmap_v2 reset
    if player.connected then
      Classes.reapply_bonuses(player)
    end
    Gui.refresh_top(player)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  ensure_storage()
  local player = game.get_player(event.player_index)
  if not player then return end
  PlayerState.ensure(player)
  Account.ensure(player.name)
  Gui.open_class_select(player)
  Gui.refresh_top(player)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  ensure_storage()
  local player = game.get_player(event.player_index)
  if not player then return end
  Account.ensure(player.name)
  local st = PlayerState.ensure(player)
  if not st.class then
    Gui.open_class_select(player)
  else
    Classes.reapply_bonuses(player)
  end
  Gui.refresh_top(player)
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  Classes.reapply_bonuses(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
  Gui.on_click(event)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  Gui.on_closed(event)
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "hrt-medkit-heal" then return end
  local source = event.source_entity
  if not source or not source.valid then return end
  local surface = source.surface
  local pos = source.position
  local m = B.medkit
  for _, character in pairs(surface.find_entities_filtered{ type = "character", position = pos, radius = m.radius }) do
    local max_h = character.max_health
    if character.health < max_h then
      character.health = math.min(max_h, character.health + m.script_heal)
      surface.create_entity{ name = "flying-text", position = character.position, text = {"hrt-rpg.healed"}, color = { r = 0.3, g = 1, b = 0.3 } }
    end
  end
end)

script.on_nth_tick(B.tick_interval, function()
  ensure_storage()
  for _, player in pairs(game.connected_players) do
    Classes.try_pending_bonuses(player)
  end
  Roadmap.tick()
  Events.tick()
end)

commands.add_command("hrt-reset-class", "Reset HRT RPG class (admin)", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player or not player.admin then
    if player then player.print({"hrt-rpg.admin-only"}) end
    return
  end
  local target = player
  if cmd.parameter and cmd.parameter ~= "" then
    target = game.get_player(cmd.parameter) or player
  end
  PlayerState.reset(target)
  Gui.open_class_select(target)
  player.print("Reset class for " .. target.name)
end)

commands.add_command("hrt-roadmap", "Open HRT roadmap", function(cmd)
  local player = game.get_player(cmd.player_index)
  if player then Gui.open_roadmap(player) end
end)

commands.add_command("hrt-force-event", "Force a world event (admin). Optional: night|hive", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player or not player.admin then return end
  local p = cmd.parameter and string.lower(cmd.parameter) or ""
  if p == "night" then
    Events.trigger_night_raid()
  elseif p == "hive" or p == "boss" then
    Events.trigger_boss_hive()
  else
    Events.trigger_random(true)
  end
end)

commands.add_command("hrt-account", "Show account level / set XP (admin: /hrt-account set <player> <level>)", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player then return end
  local param = cmd.parameter or ""
  local set_name, set_lvl = param:match("^set%s+(%S+)%s+(%d+)$")
  if set_name then
    if not player.admin then
      player.print({ "hrt-rpg.admin-only" })
      return
    end
    local acc = Account.ensure(set_name)
    acc.level = tonumber(set_lvl) or 1
    player.print("Account " .. set_name .. " level = " .. acc.level)
    return
  end
  local acc = Account.ensure(player.name)
  player.print({ "hrt-rpg.account-status", acc.level or 1, acc.xp or 0, acc.seasons_finished or 0 })
end)

commands.add_command("hrt-paragon", "Grant/list paragons (admin: /hrt-paragon give <player> <id>)", function(cmd)
  local player = game.get_player(cmd.player_index)
  if not player then return end
  local param = cmd.parameter or ""
  local target, pid = param:match("^give%s+(%S+)%s+(%S+)$")
  if target then
    if not player.admin then
      player.print({ "hrt-rpg.admin-only" })
      return
    end
    if Account.grant_paragon(target, pid) then
      local tp = game.get_player(target)
      if tp then Classes.reapply_bonuses(tp) end
      player.print("Paragon " .. pid .. " → " .. target)
    else
      player.print("Unknown paragon id")
    end
    return
  end
  local acc = Account.ensure(player.name)
  local ids = {}
  for id in pairs(acc.paragons or {}) do ids[#ids + 1] = id end
  table.sort(ids)
  player.print({ "hrt-rpg.paragon-list", (#ids > 0) and table.concat(ids, ", ") or "-" })
end)

-- Export helpers for other stages
remote.add_interface("hrt-rpg", {
  get_class = function(player_index)
    local st = storage.players[player_index]
    return st and st.class or nil
  end,
  give_xp = function(player_name, amount)
    RpgBridge.give_xp(player_name, amount)
    Account.add_xp(player_name, amount)
  end,
  account_level = function(player_name)
    return Account.ensure(player_name).level
  end,
  grant_paragon = function(player_name, paragon_id)
    return Account.grant_paragon(player_name, paragon_id)
  end,
  season_complete = function(player_name, paragon_id)
    Account.on_season_complete(player_name, paragon_id)
  end,
})
