AllPlayers = {};

level:onnotify("connected", function (player)
    table.insert(AllPlayers, player);
    
    player:onnotifyonce("disconnect", function ()
        for i, p in ipairs(AllPlayers) do
            if p == player then
                table.remove(AllPlayers, i);
                break;
            end
        end
    end)
end);

local curObjectID = 32;

function CreateWaypoint(origin, icon, team)
    curObjectID = curObjectID - 1;

    game:objectivestate(curObjectID, "active");
    game:objectiveposition(curObjectID, origin)
    game:objectiveicon(curObjectID, icon)

    if team ~= nil then
        game:objectiveteam(curObjectID, team);
    end

    local hud = nil;
    
    if team ~= nil then
        hud = game:newteamhudelem(team);
    else
        hud = game:newhudelem();
    end

    hud.x = origin.x;
    hud.y = origin.y;
    hud.z = origin.z;
    hud.alpha = 0.85;
    hud.archived = 1;

    hud:setmaterial(icon, 15, 15);
    hud:setwaypoint(true);

    return { curObjectID, hud };
end

function CreateTrigger(origin, radius, height)
    local trigger = game:spawn("trigger_radius", origin, 0, radius, height);
    return trigger;
end

function ParseVector(obj)
    return vector:new(obj.x, obj.y, obj.z);
end

function GetOtherTeam(team)
    if team == "allies" then 
        return "axis"; 
    end

    return "allies";
end
