BaseUsable = {};

local usables = {};

function BaseUsable:new(origin, angles, type, range)
    local this = {
        entity = SpawnBox(origin, angles, type),
        -- trigger = game:spawn("script_origin", origin) , -- CreateTrigger(origin, range, range),
        origin = origin,
        squaredRange = range ^ 2,
        use_function = function (player)
            player:iclientprintlnbold("You used this!");
        end,
        last_use_time = 0,
        hint_text = "Press ^3[{+activate}] ^7to use.",
        team = "all"
    };

    this.update_hint_text = function ()
        this.entity:sethintstring(this.hint_text);
    end;

    setmetatable(this, self);

    this.entity:setcursorhint("HINT_ACTIVE");
    this.entity:sethintstring(this.hint_text);
    this.entity:makeusable();

    this.entity:onnotify("trigger", function (player)
        this.use_function(player);
    end)

    table.insert(usables, this);

    return this;
end

table.insert(PlayerSpawnedHooks, function (player)
    for _, usable in pairs(usables) do
        if usable.team == "all" then
            usable.entity:enableplayeruse(player);
        elseif usable.team == player.team then
            usable.entity:enableplayeruse(player);
        else
            usable.entity:disableplayeruse(player);
        end
    end
end);

require("useables.gambler");
