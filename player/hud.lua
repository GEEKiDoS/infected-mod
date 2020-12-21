local playerHuds_id = {};

table.insert(PlayerConnectedHooks, function (player)
    local playerId = player:getentitynumber();
    
    local hud = {};

    local moneyhud = game:newclienthudelem(player);
    hud.moneyhud = moneyhud;
    moneyhud.alpha = 0.95;
    moneyhud.font = "bigfixed";
    moneyhud.fontscale = 1.0;
    moneyhud.alignx = "right";
    moneyhud.vertalign = "middle";
    moneyhud.horzalign = "right";
    moneyhud.x = 25;
    moneyhud.y = 100;
    moneyhud:settext("^3$: ^7500");

    playerHuds_id[playerId] = hud;
end);

function GetPlayerHud(player)
    return playerHuds_id[player:getentitynumber()];
end
