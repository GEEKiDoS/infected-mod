Gambler = {};

local rollGamblerResult = function (player)
    -- for now...
    player:iclientprintlnbold("^1You DIED");
    player:suicide();
end

function Gambler:new(origin, angles)
    local this = BoxUsable:new(origin, angles, 3);
    this.user = nil;
    this.cost = 500;
    this.target = "allies";
    this.reset_hint_text = function ()
        this.hint_text = "Press ^3[{+activate}] ^7to use gambler [Cost: ^2$^3" .. this.cost .. "^7].";
        this.update_hint_text();
    end;
    this.use_function = function(player)
        if this.user ~= nil then
            return;
        end

        if GetPlayerMoney(player) < this.cost then
            player:iclientprintlnbold("You don't have enough cash.");
            return;
        end

        PlayerMoneyAdd(player, -500);
        
        this.user = player;
        this.hint_text = "Gambler is in use.";
        this.update_hint_text();
        
        local i = 10;
        
        local timer = game:oninterval(function ()
            player:iclientprintlnbold("^2" .. i);
            player:playlocalsound("match_countdown_tick");
            i = i - 1;
        end, 1000);

        game:ontimeout(function ()
            timer:clear();
            rollGamblerResult(player);

            this.user = nil;
            this.reset_hint_text();
        end, 11000);
    end

    this.reset_hint_text();

    local tmp_origin = vector:new(origin.x, origin.y, origin.z + 40);
    this.waypoint = CreateWaypoint(tmp_origin, "icon_perks_gambler", "allies");

    tmp_origin.z = tmp_origin.z - 23;
    this.laptop = game:spawn("script_model", tmp_origin);
    this.laptop:setmodel("weapon_uav_control_unit_iw6");

    this.laptop:rotateyaw(-360, 7);

    game:oninterval(function ()
        this.laptop:rotateyaw(-360, 7);
    end, 7000);

    return this;
end

game:precachematerial("icon_perks_gambler");
game:precachemodel("weapon_uav_control_unit_iw6");
