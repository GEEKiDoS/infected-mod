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

local curObjectID = 0;

function CreateWaypoint(origin, icon)
    game:objectivestate(31 - curObjectID, "active");
    game:objectiveposition(31 - curObjectID, origin)
    game:objectiveicon(31 - curObjectID, icon)

    curObjectID = curObjectID + 1;

    local hud = game:newhudelem();
    hud.x = origin.x;
    hud.y = origin.y;
    hud.z = origin.z;
    hud.alpha = 0.85;
    hud.archived = 1;

    hud:setmaterial(icon, 15, 15);
    hud:setwaypoint(true);

    return curObjectID;
end

function CreateTrigger(origin, radius, height)
    local trigger = game:spawn("trigger_radius", origin, 1, radius, height);
    return trigger;
end

function ParseVector(obj)
    return vector:new(obj.x, obj.y, obj.z);
end
