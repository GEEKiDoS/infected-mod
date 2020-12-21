local playerSpawnPoints = {};
local flarefx = game:loadfx("fx/misc/flare_ambient");

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

        local tagAngles = glowStick:gettagangles("tag_fire_fx");
        local fxEnt = game:spawnfx(flarefx, glowStick:gettagorigin("tag_fire_fx"), game:anglestoforward(tagAngles), game:anglestoup(tagAngles));
        
        game:triggerfx(fxEnt);

        playerSpawnPoints[playerId] = {
            stick = glowStick,
            fx = fxEnt,
            position = playerPos
        };
    end)

    player:onnotifyonce("death", function ()
        tiMonitor:clear();
    end);

    local playerId = player:getentitynumber();

    if playerSpawnPoints[playerId] ~= nil then
        local p = playerSpawnPoints[playerId];

        player:setorigin(p.position);
        p.stick:stoploopsound();
        p.fx:delete();

        game:ontimeout(function ()
            p.stick:delete();
        end, 5000);

        playerSpawnPoints[playerId] = nil;
        return;
    end
end);

game:precachemodel("emergency_flare_iw6");
