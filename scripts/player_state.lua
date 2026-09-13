local PlayerState = {}

local function migrate(st)
  if st.subclass and not st.subclass_common then
    st.subclass_common = st.subclass
  end
  st.subclass = nil
  st.subclass_common = st.subclass_common or nil
  st.subclass_spec = st.subclass_spec or nil
  st.roadmap_index = st.roadmap_index or 1
  st.quest_progress = st.quest_progress or {}
  st.unlocked_rewards = st.unlocked_rewards or {}
  st.distance_accum = st.distance_accum or 0
  st.last_pos = st.last_pos or nil
  st.supply_chests = st.supply_chests or {}
  -- Breaking roadmap trees in 0.2.0: drop old short-chain progress
  if not st.roadmap_v2 then
    st.roadmap_index = 1
    st.quest_progress = {}
    st.roadmap_v2 = true
  end
  return st
end

function PlayerState.ensure(player)
  storage.players = storage.players or {}
  local st = storage.players[player.index]
  if not st then
    st = {
      class = nil,
      subclass_common = nil,
      subclass_spec = nil,
      roadmap_index = 1,
      quest_progress = {},
      unlocked_rewards = {},
      body_locked = false,
      starter_given = false,
      roadmap_v2 = true,
      distance_accum = 0,
      last_pos = nil,
      supply_chests = {},
    }
    storage.players[player.index] = st
  else
    migrate(st)
  end
  return st
end

function PlayerState.reset(player)
  storage.players[player.index] = nil
  PlayerState.ensure(player)
  if player.gui.screen.hrt_class_select then player.gui.screen.hrt_class_select.destroy() end
  if player.gui.screen.hrt_roadmap then player.gui.screen.hrt_roadmap.destroy() end
  if player.gui.screen.hrt_subclass then player.gui.screen.hrt_subclass.destroy() end
end

function PlayerState.get(player)
  return PlayerState.ensure(player)
end

return PlayerState
