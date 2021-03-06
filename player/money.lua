local bank = {};

table.insert(PlayerConnectedHooks, function (player)
    local playerId = player:getentitynumber();
    bank[playerId] = 500;
    UpdatePlayerMoneyDisplay(player);
end);

table.insert(PlayerSpawnedHooks, function (player)
    UpdatePlayerMoneyDisplay(player);
end)

function UpdatePlayerMoneyDisplay(player)
    local hud = GetPlayerHud(player).moneyhud;

    if player.team == "allies" then
        hud:settext("^3$: ^7" .. GetPlayerMoney(player));
    else
        hud:settext("");
    end
end

function GetPlayerMoney(player)
    local playerId = player:getentitynumber();

    return bank[playerId];
end

function SetPlayerMoney(player, cash)
    local playerId = player:getentitynumber();
    bank[playerId] = cash;

    UpdatePlayerMoneyDisplay(player);
end

function PlayerMoneyAdd(player, cash)
    local playerId = player:getentitynumber();
    bank[playerId] = bank[playerId] + cash;

    UpdatePlayerMoneyDisplay(player);

    return bank[playerId];
end

table.insert(PlayerSayHooks, function (player, msg)
    if game:getdvarint("sv_cheats") == 1 then
        if msg == "!10000" then
            PlayerMoneyAdd(player, 10000);
        end
    end
end);

table.insert(PlayerKilledHooks, function ()
    
end);
