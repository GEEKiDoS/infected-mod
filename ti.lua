local playerSpawnPoints = {};
local flarefx = {
    enemy = game:loadfx("fx/misc/flare_ambient"),
    friendly = game:loadfx("fx/misc/flare_ambient_green")
};

local watch_player_team = function ()
    for _, p in pairs(playerSpawnPoints) do
        p.fx_friendly:hide();
        p.fx_enemy:hide();

        for _, player in pairs(AllPlayers) do
            if player.team == p.team then
                p.fx_friendly:showtoplayer(player);
            else
                p.fx_enemy:showtoplayer(player);
            end
        end
    end
end

table.insert(PlayerSpawnedHooks, function (player)
    local tiMonitor = player:onnotify("grenade_fire", function (ent, weapName)
        if weapName ~= "flare_mp" then
            return;
        end

        local playerId = player:getentitynumber();

        if playerSpawnPoints[playerId] ~= nil then
            player:givemaxammo("flare_mp");
            return;
        end

        local playerPos = player.origin;
        local groundPos = game:playerphysicstrace(vector:new(playerPos.x, playerPos.y, playerPos.z + 16), vector:new(playerPos.x, playerPos.y, playerPos.z - 2048));
        groundPos.z = groundPos.z + 1;

        local glowStick = game:spawn("script_model", groundPos);
        glowStick.angles = player.angles;
        glowStick.team = player.team;
        glowStick.owner = player;
        glowStick:setmodel("emergency_flare_iw6");
        glowStick:playloopsound("emt_road_flare_burn");
        glowStick:setcandamage(true);

        local selfUseTrigger = BaseUsable:new(game:spawn("script_origin", groundPos));
        selfUseTrigger.target = player;
        selfUseTrigger.hint_text = "Press ^3[{+activate}] ^7to pick up."
        selfUseTrigger.update_hint_text();
        selfUseTrigger.update_usable_for_all_player();

        local enemyUseTrigger = BaseUsable:new(game:spawn("script_origin", groundPos));
        enemyUseTrigger.target = GetOtherTeam(player.team);
        enemyUseTrigger.hint_text = "Press ^3[{+activate}] ^7to destroy tactical insertion."
        enemyUseTrigger.update_hint_text();
        enemyUseTrigger.update_usable_for_all_player();

        local damageListener = nil;

        local tagAngles = glowStick:gettagangles("tag_fire_fx");
        local tagOrigin = glowStick:gettagorigin("tag_fire_fx");
        local tagForwardVec = game:anglestoforward(tagAngles);
        local tagUpVec = game:anglestoup(tagAngles);
        local fxEntEnemy = game:spawnfx(flarefx.enemy, tagOrigin, tagForwardVec, tagUpVec);
        local fxEntFriendly = game:spawnfx(flarefx.friendly, tagOrigin, tagForwardVec, tagUpVec);

        game:triggerfx(fxEntEnemy);
        game:triggerfx(fxEntFriendly);

        local removeTI = function ()
            glowStick:stoploopsound();
            fxEntEnemy:delete();
            fxEntFriendly:delete();

            selfUseTrigger:deleteSelf();
            enemyUseTrigger:deleteSelf();

            selfUseTrigger.entity:delete();
            enemyUseTrigger.entity:delete();

            damageListener:clear();

            playerSpawnPoints[playerId] = nil;

            game:ontimeout(function ()
                glowStick:delete();
            end, 5000);
        end

        local onUse = function (user)
            if user ~= player then
                player:iclientprintlnbold("Your ^2tactical insertion ^7has been ^1denied!");
            else
                player:givemaxammo("flare_mp");
            end

            removeTI();
        end;
   
        selfUseTrigger.use_function = onUse;
        enemyUseTrigger.use_function = onUse;
        damageListener = glowStick:onnotify("damage", function (dmage, attacker)
            if attacker.team == player.team then
                return;
            end

            player:iclientprintlnbold("Your ^2tactical insertion ^7has been ^1denied!");
            removeTI();
        end);

        playerSpawnPoints[playerId] = {
            position = playerPos,
            fx_enemy = fxEntEnemy,
            fx_friendly = fxEntFriendly,
            team = player.team,
            removeSelf = removeTI
        };

        -- update fx for all players
        watch_player_team();
    end)

    player:onnotifyonce("death", function ()
        tiMonitor:clear();
    end);

    local playerId = player:getentitynumber();

    if playerSpawnPoints[playerId] ~= nil then
        local p = playerSpawnPoints[playerId];

        player:setorigin(p.position);

        p.removeSelf();
    end
end);

game:precachemodel("emergency_flare_iw6");

level:onnotify("joined_team", watch_player_team);
level:onnotify("player_spawned", watch_player_team);
