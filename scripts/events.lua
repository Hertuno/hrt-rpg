local Account = require("scripts.account")
local PlayerState = require("scripts.player_state")
local B = require("scripts.balance")

local Events = {}

local E = B.events

function Events.schedule_next(from_tick)
  storage.events = storage.events or {}
  local now = from_tick or game.tick
  storage.events.next_tick = now + E.interval_ticks + math.random(0, E.interval_jitter_ticks)
  storage.events.active = nil
end

local function announce(msg)
  game.print(msg)
  for _, player in pairs(game.connected_players) do
    player.play_sound{ path = "utility/alert_destroyed" }
  end
end

local function origin_pos()
  local origin = { x = 0, y = 0 }
  if game.connected_players[1] and game.connected_players[1].character then
    origin = game.connected_players[1].position
  end
  return origin
end

local function is_night(surface)
  return surface.darkness >= E.darkness_threshold
end

local function class_mix_near(surface, pos, radius)
  local classes = {}
  local count = 0
  for _, player in pairs(game.connected_players) do
    if player.character and player.character.surface == surface then
      local dx = player.position.x - pos.x
      local dy = player.position.y - pos.y
      if (dx * dx + dy * dy) <= (radius * radius) then
        local st = PlayerState.get(player)
        if st.class and not classes[st.class] then
          classes[st.class] = true
          count = count + 1
        end
      end
    end
  end
  return count, classes
end

local function spawn_biter_wave(night)
  local surface = game.get_surface(1)
  if not surface then return end
  local force = game.forces.enemy
  local origin = origin_pos()
  local angle = math.random() * math.pi * 2
  local w = night and E.night_wave or E.day_wave
  local dist = w.dist_base + math.random(0, w.dist_jitter)
  local pos = { x = origin.x + math.cos(angle) * dist, y = origin.y + math.sin(angle) * dist }
  pos = surface.find_non_colliding_position("character", pos, 40, 1) or pos
  local names = night
      and { "medium-biter", "medium-biter", "big-biter", "medium-spitter", "small-biter" }
    or { "small-biter", "small-biter", "medium-biter", "small-spitter" }
  local count = w.count_base + math.random(0, w.count_jitter)
  for _ = 1, count do
    local n = names[math.random(#names)]
    local p = { x = pos.x + math.random(-10, 10), y = pos.y + math.random(-10, 10) }
    p = surface.find_non_colliding_position(n, p, 12, 1)
    if p and prototypes.entity[n] then
      surface.create_entity{ name = n, position = p, force = force }
    end
  end
  if night then
    announce({ "hrt-rpg.event-night-raid", math.floor(pos.x), math.floor(pos.y) })
  else
    announce({ "hrt-rpg.event-biters", math.floor(pos.x), math.floor(pos.y) })
  end
  storage.events.active = {
    type = night and "night_raid" or "biters",
    until_tick = game.tick + 60 * 60 * w.duration_min,
  }
end

local function spawn_ore_event()
  local surface = game.get_surface(1)
  if not surface then return end
  local origin = origin_pos()
  local angle = math.random() * math.pi * 2
  local o = E.ore
  local dist = o.dist_base + math.random(0, o.dist_jitter)
  local pos = { x = origin.x + math.cos(angle) * dist, y = origin.y + math.sin(angle) * dist }
  local ore = ({ "iron-ore", "copper-ore", "stone", "coal" })[math.random(4)]
  for _ = 1, o.tiles do
    local p = { x = pos.x + math.random(-5, 5), y = pos.y + math.random(-5, 5) }
    surface.create_entity{ name = ore, position = p, amount = o.amount_base + math.random(0, o.amount_jitter), force = "neutral" }
  end
  local cpos = surface.find_non_colliding_position("steel-chest", pos, 10, 1) or pos
  local chest = surface.create_entity{ name = "steel-chest", position = cpos, force = "player" }
  if chest and chest.insert then
    chest.insert{ name = "explosives", count = o.chest_explosives }
    chest.insert{ name = "repair-pack", count = o.chest_repair }
  end
  announce({ "hrt-rpg.event-ore", ore, math.floor(pos.x), math.floor(pos.y) })
  storage.events.active = { type = "ore", until_tick = game.tick + 60 * 60 * o.duration_min, ore = ore }
end

local function spawn_boss_hive()
  local surface = game.get_surface(1)
  if not surface then return end
  local force = game.forces.enemy
  local origin = origin_pos()
  local angle = math.random() * math.pi * 2
  local h = E.boss_hive
  local dist = h.dist_base + math.random(0, h.dist_jitter)
  local pos = { x = origin.x + math.cos(angle) * dist, y = origin.y + math.sin(angle) * dist }
  pos = surface.find_non_colliding_position("biter-spawner", pos, 50, 2) or pos

  local nest_name = prototypes.entity["biter-spawner"] and "biter-spawner" or "enemy-spawner"
  if prototypes.entity[nest_name] then
    surface.create_entity{ name = nest_name, position = pos, force = force }
  end
  if prototypes.entity["spitter-spawner"] then
    local p2 = { x = pos.x + 6, y = pos.y }
    p2 = surface.find_non_colliding_position("spitter-spawner", p2, 10, 1) or p2
    surface.create_entity{ name = "spitter-spawner", position = p2, force = force }
  end
  for _, n in ipairs({ "big-biter", "big-biter", "behemoth-biter", "big-spitter" }) do
    if prototypes.entity[n] then
      local p = surface.find_non_colliding_position(n, { x = pos.x + math.random(-8, 8), y = pos.y + math.random(-8, 8) }, 12, 1)
      if p then
        surface.create_entity{ name = n, position = p, force = force }
      end
    end
  end

  announce({ "hrt-rpg.event-boss-hive", math.floor(pos.x), math.floor(pos.y) })
  storage.events.active = {
    type = "boss_hive",
    until_tick = game.tick + 60 * 60 * h.duration_min,
    pos = pos,
    rewarded = false,
  }
end

local function try_boss_reward()
  local active = storage.events and storage.events.active
  if not active or active.type ~= "boss_hive" or active.rewarded then return end
  local surface = game.get_surface(1)
  if not surface or not active.pos then return end
  local h = E.boss_hive
  local nests = surface.find_entities_filtered{
    position = active.pos,
    radius = h.nest_clear_radius,
    force = "enemy",
    type = "unit-spawner",
  }
  if #nests > 0 then return end

  local mix, _ = class_mix_near(surface, active.pos, h.mix_radius)
  active.rewarded = true
  if mix >= h.mix_min_classes then
    announce({ "hrt-rpg.event-boss-hive-win-mix", mix })
    for _, player in pairs(game.connected_players) do
      Account.add_xp(player.name, h.reward_mix_account_xp)
      if player.character then
        player.insert{ name = h.reward_armor, count = h.reward_armor_count }
        player.insert{ name = h.reward_capsules, count = h.reward_capsules_count }
      end
    end
  else
    announce({ "hrt-rpg.event-boss-hive-win-solo", mix })
    for _, player in pairs(game.connected_players) do
      Account.add_xp(player.name, h.reward_solo_account_xp)
    end
  end
end

function Events.trigger_random(force_trigger)
  if not force_trigger and storage.events and storage.events.active and game.tick < (storage.events.active.until_tick or 0) then
    return
  end
  local surface = game.get_surface(1)
  local night = surface and is_night(surface)
  local roll = math.random()
  local w = E.weights
  if night and roll < w.night_raid_chance then
    spawn_biter_wave(true)
  elseif roll < w.hive_chance then
    spawn_boss_hive()
  elseif roll < w.day_wave_chance then
    spawn_biter_wave(false)
  else
    spawn_ore_event()
  end
  Events.schedule_next()
end

function Events.trigger_night_raid()
  spawn_biter_wave(true)
  Events.schedule_next()
end

function Events.trigger_boss_hive()
  spawn_boss_hive()
  Events.schedule_next()
end

function Events.tick()
  storage.events = storage.events or { next_tick = game.tick + E.interval_ticks }
  storage.events.last_night_check = storage.events.last_night_check or 0

  if storage.events.active and game.tick >= (storage.events.active.until_tick or 0) then
    storage.events.active = nil
  end

  if storage.events.active and storage.events.active.type == "boss_hive" then
    try_boss_reward()
  end

  if game.tick - storage.events.last_night_check >= E.night_check_interval then
    storage.events.last_night_check = game.tick
    local surface = game.get_surface(1)
    if surface and #game.connected_players > 0 then
      local night = is_night(surface)
      if night and not storage.events.night_raid_done then
        storage.events.night_raid_done = true
        if not (storage.events.active and game.tick < (storage.events.active.until_tick or 0)) then
          spawn_biter_wave(true)
        end
      elseif not night then
        storage.events.night_raid_done = false
      end
    end
  end

  if game.tick >= (storage.events.next_tick or 0) then
    if #game.connected_players > 0 then
      Events.trigger_random(false)
    else
      Events.schedule_next()
    end
  end
end

return Events
