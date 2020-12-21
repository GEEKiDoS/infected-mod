local onPlayerSpawned = function (player)
    -- workaroud for tls stuff
    game:ontimeout(function ()
        for _, hook in pairs(PlayerSpawnedHooks) do
            hook(player);
        end

        player:freezecontrols(false);
    end, 100);
end

local saveMap = function ()
    local jsonstr = json.encode(Map);
    local f = io.open(("iw6x\\scripts\\inf_mod\\maps\\%s.json"):format(game:getdvar("mapname")), "w");
    f:write(jsonstr);
    f:flush();
    f:close();
end

local loadMap = function ()
    local mapFile = ("iw6x\\scripts\\inf_mod\\maps\\%s.json"):format(game:getdvar("mapname"))

    local f = io.open(mapFile, "r");

    if f == nil then
        Map = {
            floors = {},
            walls = {},
            ramps = {},
            tps = {},
            gamblers = {},
        }
        return;
    end

    local jsonstr = f:read("*a");
    Map = json.decode(jsonstr);

    for _, floor in ipairs(Map.floors) do
        local startpoint = ParseVector(floor.startpoint);
        local endpoint = ParseVector(floor.endpoint);

        SpawnFloor(startpoint, endpoint);
    end

    for _, wall in ipairs(Map.walls) do
        local startpoint = ParseVector(wall.startpoint);
        local endpoint = ParseVector(wall.endpoint);

        SpawnWall(startpoint, endpoint);
    end

    for _, ramp in ipairs(Map.ramps) do
        local startpoint = ParseVector(ramp.startpoint);
        local endpoint = ParseVector(ramp.endpoint);

        SpawnRamp(startpoint, endpoint);
    end

    for _, tp in ipairs(Map.tps) do
        local startpoint = ParseVector(tp.startpoint);
        local endpoint = ParseVector(tp.endpoint);

        CreateTP(startpoint, endpoint);
    end

    for _, gambler in ipairs(Map.gamblers) do
        local origin = ParseVector(gambler.origin);
        local angles = ParseVector(gambler.angles);

        Gambler:new(origin, angles);
    end

    print(("Map loaded\nObject counts:\n%d Floors\n%d Walls\n%d Ramps\n%d Teleport points"):format(#Map.floors, #Map.walls, #Map.ramps, #Map.tps));

    io.close(f);
end

local rampStart = nil;
local floorStart = nil;
local wallStart = nil;
local tpStart = nil;

local onPlayerSay = function (player, msg)
    msg = string.lower(msg);

    if msg == "!sc" or msg == "!s" then
        game:ontimeout(function () player:suicide() end, 1);
    end

    if game:getdvarint("scr_mapedit_editmode") ~= 1 then
        return
    end

    if msg == "!save" then
        saveMap();
        player:iclientprintlnbold("Map " .. game:getdvar("mapname") .. ".json saved!");
    elseif msg == "!ramp" then
        if rampStart == nil then
            rampStart = player.origin;
            player:iclientprintlnbold(("Ramp start point (%f %f %f)"):format(rampStart.x, rampStart.y, rampStart.z));
        else
            local endp = player.origin;
            player:iclientprintlnbold(("Ramp end point (%f %f %f)"):format(endp.x, endp.y, endp.z));
            SpawnRamp(rampStart, endp);
            
            table.insert(Map.ramps, {
                startpoint = { x = rampStart.x, y = rampStart.y, z = rampStart.z },
                endpoint = { x = endp.x, y = endp.y, z = endp.z }
            })

            rampStart = nil;
        end
    elseif msg == "!floor" then
        if floorStart == nil then
            floorStart = player.origin;
            player:iclientprintlnbold(("Floor start point (%f %f %f)"):format(floorStart.x, floorStart.y, floorStart.z));
        else
            local endp = player.origin;
            player:iclientprintlnbold(("Floor end point (%f %f %f)"):format(endp.x, endp.y, endp.z));
            SpawnFloor(floorStart, endp);

            table.insert(Map.floors, {
                startpoint = { x = floorStart.x, y = floorStart.y, z = floorStart.z },
                endpoint = { x = endp.x, y = endp.y, z = endp.z }
            })

            floorStart = nil;
        end
    elseif msg == "!wall" then
        if wallStart == nil then
            wallStart = player.origin;
            player:iclientprintlnbold(("Wall start point (%f %f %f)"):format(wallStart.x, wallStart.y, wallStart.z));
        else
            local endp = player.origin;
            player:iclientprintlnbold(("Wall end point (%f %f %f)"):format(endp.x, endp.y, endp.z));
            SpawnWall(wallStart, endp);

            table.insert(Map.walls, {
                startpoint = { x = wallStart.x, y = wallStart.y, z = wallStart.z },
                endpoint = { x = endp.x, y = endp.y, z = endp.z }
            })

            wallStart = nil;
        end
    elseif msg == "!tp" then
        if tpStart == nil then
            tpStart = player.origin;
            player:iclientprintlnbold(("Teleport point start point (%f %f %f)"):format(tpStart.x, tpStart.y, tpStart.z));
        else
            local endp = player.origin;
            player:iclientprintlnbold(("Teleport point end point (%f %f %f)"):format(endp.x, endp.y, endp.z));
            CreateTP(tpStart, endp);

            table.insert(Map.tps, {
                startpoint = { x = tpStart.x, y = tpStart.y, z = tpStart.z },
                endpoint = { x = endp.x, y = endp.y, z = endp.z }
            })

            tpStart = nil;
        end
    elseif msg == "!gambler" then
        local origin = player.origin;
        origin.z = origin.z + 15;

        local angles = player.angles;

        Gambler:new(origin, angles);

        table.insert(Map.gamblers, {
            origin = { x = origin.x, y = origin.y, z = origin.z },
            angles = { x = angles.x, y = angles.y, z = angles.z }
        })
    end

    for _, hook in ipairs(PlayerSayHooks) do
        hook(player, msg);
    end
end

local onPlayerConnected = function (player)
    -- Player events
    local spawnlistenr = player:onnotify("spawned_player", function() onPlayerSpawned(player) end);
    local saylistener = player:onnotify("say", function(msg) onPlayerSay(player, msg) end);
    local say_teamlistener player:onnotify("say_team", function(msg) onPlayerSay(player, msg) end);

    player:onnotifyonce("disconnect", function ()
        spawnlistenr:clear();
        saylistener:clear();
        say_teamlistener:clear();
    end)

    for _, hook in pairs(PlayerConnectedHooks) do
        hook(player);
    end
end

game:setdvarifuninitialized("scr_mapedit_editmode", "0");
game:setdvar("jump_slowdownEnable", 0);

print("Infected mod by GEEKiDoS");
if game:getdvarint("scr_mapedit_editmode") == 1 then
    print("Edit mode enabled");
    print("Commands:")
    print("!tp - Create teleport");
    print("!wall - Create wall");
    print("!floor - Create floor");
    print("!ramp - Create ramp");
    print("!gambler - Create gambler");
    print("!save - save the map");
else
    print("Edit mode disabled");
    print("Set scr_mapedit_editmode to 1 and restart game to enable editmode.")
end

level:onnotify("connected", onPlayerConnected);
loadMap();
