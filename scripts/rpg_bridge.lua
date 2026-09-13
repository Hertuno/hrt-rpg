local RpgBridge = {}

function RpgBridge.give_xp(player_name, amount)
  amount = amount or 0
  if amount == 0 then return end
  -- Prefer RPGsystem remote if present
  if remote.interfaces["RPG"] then
    local ok = pcall(function()
      if remote.interfaces["RPG"]["gain_xp"] then
        remote.call("RPG", "gain_xp", player_name, amount)
      elseif remote.interfaces["RPG"]["give_xp"] then
        remote.call("RPG", "give_xp", amount)
      end
    end)
    if ok then return end
  end
  -- Fallback: store local XP tally and print
  storage.local_xp = storage.local_xp or {}
  storage.local_xp[player_name] = (storage.local_xp[player_name] or 0) + amount
  local player = game.get_player(player_name)
  if player then
    player.print({ "hrt-rpg.xp-gained", amount, storage.local_xp[player_name] })
  end
end

return RpgBridge
