local Account = require("scripts.account")
local Classes = require("scripts.classes")
local PlayerState = require("scripts.player_state")
local Roadmap = require("scripts.roadmap")
local Subclass = require("scripts.subclass")

local Gui = {}

local function destroy_named(player, name)
  local el = player.gui.screen[name]
  if el then el.destroy() end
end

function Gui.refresh_top(player)
  local top = player.gui.top
  if top.hrt_top then top.hrt_top.destroy() end
  local flow = top.add{ type = "flow", name = "hrt_top", direction = "horizontal" }
  flow.add{ type = "button", name = "hrt_btn_roadmap", caption = { "hrt-rpg.btn-roadmap" }, style = "frame_action_button" }
  local st = PlayerState.get(player)
  local label = flow.add{ type = "label", name = "hrt_status" }
  if st.class then
    label.caption = Roadmap.progress_text(player)
  else
    label.caption = { "hrt-rpg.no-class" }
  end
end

function Gui.open_class_select(player)
  destroy_named(player, "hrt_class_select")
  local acc = Account.ensure(player.name)
  local frame = player.gui.screen.add{
    type = "frame",
    name = "hrt_class_select",
    direction = "vertical",
    caption = { "hrt-rpg.choose-class" },
  }
  frame.auto_center = true
  frame.add{ type = "label", caption = { "hrt-rpg.account-level", acc.level or 1 } }
  local list = frame.add{ type = "flow", direction = "vertical", name = "list" }
  local ids = {}
  for id in pairs(Classes.defs) do ids[#ids + 1] = id end
  table.sort(ids)
  for _, id in ipairs(ids) do
    local def = Classes.defs[id]
    local unlocked = Account.class_unlocked(player.name, id)
    local caption = def.title
    if not unlocked then
      local need = Account.unlock_requirement(id) or "?"
      caption = { "hrt-rpg.class-locked-btn", def.title, need }
    end
    local row = list.add{ type = "flow", direction = "horizontal" }
    row.add{
      type = "button",
      name = "hrt_pick_class__" .. id,
      caption = caption,
      enabled = unlocked,
      tags = { hrt_action = "pick_class", class_id = id },
    }
  end
  player.opened = frame
end

function Gui.open_roadmap(player)
  destroy_named(player, "hrt_roadmap")
  local st = PlayerState.get(player)
  local frame = player.gui.screen.add{
    type = "frame",
    name = "hrt_roadmap",
    direction = "vertical",
    caption = { "hrt-rpg.roadmap-title" },
  }
  frame.auto_center = true
  frame.add{ type = "label", caption = Roadmap.progress_text(player) }

  local slots = frame.add{ type = "label", name = "hrt_slots" }
  local common_title = st.subclass_common and (Subclass.defs[st.subclass_common] and Subclass.defs[st.subclass_common].title) or { "hrt-rpg.slot-empty" }
  local spec_title = st.subclass_spec and (Subclass.defs[st.subclass_spec] and Subclass.defs[st.subclass_spec].title) or { "hrt-rpg.slot-empty" }
  slots.caption = { "hrt-rpg.subclass-slots", common_title, spec_title }

  if st.class and Roadmap.trees[st.class] then
    local current = Roadmap.trees[st.class][st.roadmap_index]
    local current_phase = current and current.phase or "early"
    for _, phase in ipairs(Roadmap.PHASES) do
      local header = frame.add{ type = "label" }
      if phase == current_phase then
        header.caption = { "hrt-rpg.phase-header-active", { "hrt-rpg.phase-" .. phase } }
      else
        header.caption = { "hrt-rpg.phase-header", { "hrt-rpg.phase-" .. phase } }
      end
      if phase == current_phase then
        for _, entry in ipairs(Roadmap.quests_in_phase(st.class, phase)) do
          local q = entry.quest
          local done = st.quest_progress[q.id] and st.quest_progress[q.id].done
          local prefix = done and "[x] " or (entry.index == st.roadmap_index and "[>] " or "[ ] ")
          frame.add{ type = "label", caption = { "", prefix, q.desc } }
        end
      end
    end
  end
  frame.add{ type = "button", name = "hrt_close_roadmap", caption = { "hrt-rpg.close" }, tags = { hrt_action = "close_roadmap" } }
  player.opened = frame
end

function Gui.open_subclass(player, tier)
  destroy_named(player, "hrt_subclass")
  tier = tier or "common"
  local st = PlayerState.get(player)
  local caption = tier == "specialized" and { "hrt-rpg.choose-subclass-spec" } or { "hrt-rpg.choose-subclass-common" }
  local frame = player.gui.screen.add{
    type = "frame",
    name = "hrt_subclass",
    direction = "vertical",
    caption = caption,
  }
  frame.auto_center = true
  frame.tags = { hrt_subclass_tier = tier }
  for _, entry in ipairs(Subclass.available_for(st.class, tier)) do
    local unlocked = Account.subclass_unlocked(player.name, entry.id)
    local tag = entry.def.class_id and { "hrt-rpg.subclass-personal", entry.def.title } or entry.def.title
    if not unlocked then
      local need = Account.SUBCLASS_UNLOCK_LEVEL[entry.id] or "?"
      tag = { "hrt-rpg.subclass-locked-btn", entry.def.title, need }
    end
    frame.add{
      type = "button",
      name = "hrt_pick_sub__" .. entry.id,
      caption = tag,
      enabled = unlocked,
      tags = { hrt_action = "pick_subclass", subclass_id = entry.id, subclass_tier = tier },
    }
  end
  player.opened = frame
end

function Gui.on_click(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local element = event.element
  if not element or not element.valid then return end
  local tags = element.tags or {}
  local action = tags.hrt_action
  if not action then
    if element.name == "hrt_btn_roadmap" then Gui.open_roadmap(player) return end
    if element.name == "hrt_close_roadmap" then destroy_named(player, "hrt_roadmap") return end
    local class_id = element.name:match("^hrt_pick_class__(.+)$")
    if class_id then
      if Classes.select(player, class_id) then
        destroy_named(player, "hrt_class_select")
        Gui.refresh_top(player)
      end
      return
    end
    local sub_id = element.name:match("^hrt_pick_sub__(.+)$")
    if sub_id then
      local tier = "common"
      local parent = element.parent
      if parent and parent.tags and parent.tags.hrt_subclass_tier then
        tier = parent.tags.hrt_subclass_tier
      end
      if Subclass.select(player, sub_id, tier) then
        destroy_named(player, "hrt_subclass")
        Gui.refresh_top(player)
      end
      return
    end
    return
  end
  if action == "pick_class" then
    if Classes.select(player, tags.class_id) then
      destroy_named(player, "hrt_class_select")
      Gui.refresh_top(player)
    end
  elseif action == "pick_subclass" then
    if Subclass.select(player, tags.subclass_id, tags.subclass_tier or "common") then
      destroy_named(player, "hrt_subclass")
      Gui.refresh_top(player)
    end
  elseif action == "close_roadmap" then
    destroy_named(player, "hrt_roadmap")
  end
end

function Gui.on_closed(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  if event.element and event.element.valid then
    if event.element.name == "hrt_class_select" or event.element.name == "hrt_roadmap" or event.element.name == "hrt_subclass" then
      event.element.destroy()
    end
  end
end

return Gui
