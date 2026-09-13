local Account = require("scripts.account")
local PlayerState = require("scripts.player_state")
local RpgBridge = require("scripts.rpg_bridge")
local B = require("scripts.balance")
local Classes = require("scripts.classes")

local Subclass = {}

-- tier / class_id / titles stay here; numeric bonuses + items from Balance
Subclass.defs = {
  logistics = {
    title = { "hrt-rpg.sub-logistics" },
    tier = "common",
    class_id = nil,
    bonuses = B.subclasses.logistics.bonuses,
    items = B.subclasses.logistics.items,
  },
  demolitionist = {
    title = { "hrt-rpg.sub-demo" },
    tier = "common",
    class_id = nil,
    bonuses = B.subclasses.demolitionist.bonuses,
    items = B.subclasses.demolitionist.items,
  },
  astronaut = {
    title = { "hrt-rpg.sub-astro" },
    tier = "common",
    class_id = nil,
    bonuses = B.subclasses.astronaut.bonuses,
    items = B.subclasses.astronaut.items,
  },
  medic = {
    title = { "hrt-rpg.sub-medic" },
    tier = "common",
    class_id = nil,
    bonuses = B.subclasses.medic.bonuses,
    items = B.subclasses.medic.items,
  },
  cartographer = {
    title = { "hrt-rpg.sub-cartographer" },
    tier = "specialized",
    class_id = "explorer",
    bonuses = B.subclasses.cartographer.bonuses,
    items = B.subclasses.cartographer.items,
  },
  field_scientist = {
    title = { "hrt-rpg.sub-field-scientist" },
    tier = "specialized",
    class_id = "explorer",
    bonuses = B.subclasses.field_scientist.bonuses,
    items = B.subclasses.field_scientist.items,
  },
  vanguard = {
    title = { "hrt-rpg.sub-vanguard" },
    tier = "specialized",
    class_id = "fighter",
    bonuses = B.subclasses.vanguard.bonuses,
    items = B.subclasses.vanguard.items,
  },
  prospector = {
    title = { "hrt-rpg.sub-prospector" },
    tier = "specialized",
    class_id = "miner",
    bonuses = B.subclasses.prospector.bonuses,
    items = B.subclasses.prospector.items,
  },
  architect = {
    title = { "hrt-rpg.sub-architect" },
    tier = "specialized",
    class_id = "engineer",
    bonuses = B.subclasses.architect.bonuses,
    items = B.subclasses.architect.items,
  },
  overwatch = {
    title = { "hrt-rpg.sub-overwatch" },
    tier = "specialized",
    class_id = "support",
    bonuses = B.subclasses.overwatch.bonuses,
    items = B.subclasses.overwatch.items,
  },
}

function Subclass.available_for(class_id, tier)
  local list = {}
  for id, def in pairs(Subclass.defs) do
    if (not tier or def.tier == tier)
      and (def.class_id == nil or def.class_id == class_id)
    then
      list[#list + 1] = { id = id, def = def }
    end
  end
  table.sort(list, function(a, b)
    return a.id < b.id
  end)
  return list
end

function Subclass.apply(player, subclass_id)
  local def = Subclass.defs[subclass_id]
  if not def or not player or not player.valid then return end
  if not (player.character and player.character.valid) then return end
  for k, v in pairs(def.bonuses or {}) do
    pcall(function()
      player[k] = (player[k] or 0) + v
    end)
  end
end

function Subclass.select(player, subclass_id, tier)
  local def = Subclass.defs[subclass_id]
  if not def then return false end
  local st = PlayerState.get(player)
  tier = tier or def.tier or "common"
  if def.tier and def.tier ~= tier then
    player.print({ "hrt-rpg.subclass-wrong-tier" })
    return false
  end
  if def.class_id and def.class_id ~= st.class then
    player.print({ "hrt-rpg.subclass-wrong-class" })
    return false
  end
  if tier == "common" then
    if st.subclass_common then
      player.print({ "hrt-rpg.subclass-locked" })
      return false
    end
  else
    if st.subclass_spec then
      player.print({ "hrt-rpg.subclass-locked" })
      return false
    end
  end
  if not Account.subclass_unlocked(player.name, subclass_id) then
    local need = Account.SUBCLASS_UNLOCK_LEVEL[subclass_id] or "?"
    player.print({ "hrt-rpg.subclass-locked-level", def.title, need })
    return false
  end
  if tier == "common" then
    st.subclass_common = subclass_id
  else
    st.subclass_spec = subclass_id
  end
  Classes.reapply_bonuses(player)
  for _, entry in ipairs(def.items or {}) do
    local name, count = entry[1], entry[2]
    if prototypes.item[name] then
      player.insert{ name = name, count = count }
    end
  end
  local A = B.account
  if tier == "specialized" then
    RpgBridge.give_xp(player.name, A.subclass_spec_rpg_xp)
    Account.add_xp(player.name, A.subclass_spec_account_xp)
  else
    RpgBridge.give_xp(player.name, A.subclass_common_rpg_xp)
    Account.add_xp(player.name, A.subclass_common_account_xp)
  end
  player.print({ "hrt-rpg.subclass-selected", def.title })
  return true
end

return Subclass
