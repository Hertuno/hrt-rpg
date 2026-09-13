local B = require("scripts.balance")

local Account = {}

local STARTER_CLASSES = {
  fighter = true,
  miner = true,
  engineer = true,
  support = true,
}

local CLASS_UNLOCK_LEVEL = B.class_unlock_level
local SUBCLASS_UNLOCK_LEVEL = B.subclass_unlock_level

local PARAGONS = {
  survivor = {
    title = { "hrt-rpg.paragon-survivor" },
    bonuses = B.paragons.survivor,
  },
  scout = {
    title = { "hrt-rpg.paragon-scout" },
    bonuses = B.paragons.scout,
  },
  artisan = {
    title = { "hrt-rpg.paragon-artisan" },
    bonuses = B.paragons.artisan,
  },
}

function Account.ensure(player_name)
  storage.accounts = storage.accounts or {}
  local acc = storage.accounts[player_name]
  if not acc then
    acc = {
      level = 1,
      xp = 0,
      unlocked_classes = {},
      unlocked_subclasses = {},
      paragons = {},
      seasons_finished = 0,
    }
    storage.accounts[player_name] = acc
  end
  return acc
end

function Account.add_xp(player_name, amount)
  local acc = Account.ensure(player_name)
  acc.xp = (acc.xp or 0) + (amount or 0)
  local per = B.account.xp_per_level
  local need = per * (acc.level or 1)
  while acc.xp >= need do
    acc.xp = acc.xp - need
    acc.level = (acc.level or 1) + 1
    need = per * acc.level
    local player = game.get_player(player_name)
    if player then
      player.print({ "hrt-rpg.account-level-up", acc.level })
    end
  end
  return acc
end

function Account.class_unlocked(player_name, class_id)
  if STARTER_CLASSES[class_id] then return true end
  local need = CLASS_UNLOCK_LEVEL[class_id]
  if not need then return true end
  local acc = Account.ensure(player_name)
  if acc.unlocked_classes[class_id] then return true end
  return (acc.level or 1) >= need
end

function Account.subclass_unlocked(player_name, subclass_id)
  local need = SUBCLASS_UNLOCK_LEVEL[subclass_id]
  if not need then return true end
  local acc = Account.ensure(player_name)
  if acc.unlocked_subclasses[subclass_id] then return true end
  return (acc.level or 1) >= need
end

function Account.unlock_requirement(class_id)
  return CLASS_UNLOCK_LEVEL[class_id]
end

function Account.grant_paragon(player_name, paragon_id)
  if not PARAGONS[paragon_id] then return false end
  local acc = Account.ensure(player_name)
  acc.paragons[paragon_id] = true
  return true
end

function Account.apply_paragons(player)
  if not player or not player.valid then return end
  if not (player.character and player.character.valid) then return end
  local acc = Account.ensure(player.name)
  for id in pairs(acc.paragons or {}) do
    local def = PARAGONS[id]
    if def and def.bonuses then
      for k, v in pairs(def.bonuses) do
        pcall(function()
          player[k] = (player[k] or 0) + v
        end)
      end
    end
  end
end

function Account.on_season_complete(player_name, paragon_id)
  local acc = Account.ensure(player_name)
  acc.seasons_finished = (acc.seasons_finished or 0) + 1
  Account.add_xp(player_name, B.account.season_complete_xp)
  if paragon_id then
    Account.grant_paragon(player_name, paragon_id)
  end
end

Account.PARAGONS = PARAGONS
Account.CLASS_UNLOCK_LEVEL = CLASS_UNLOCK_LEVEL
Account.SUBCLASS_UNLOCK_LEVEL = SUBCLASS_UNLOCK_LEVEL
Account.STARTER_CLASSES = STARTER_CLASSES

return Account
