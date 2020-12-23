BaseUsable = {};

local usables = {};

function BaseUsable:new(entity)
    local this = {
        entity = entity;
        hint_text = "Press ^3[{+activate}] ^7to use.",
        target = "all"
    };

    setmetatable(this, self);

    this.use_function = function (player)
        player:iclientprintlnbold("You used this!");
    end;

    this.update_hint_text = function ()
        this.entity:sethintstring(this.hint_text);
    end;

    this.update_usable_for_player = function (player)
        -- if target is string then it's must be a team
        if type(this.target) == "string" then
            if this.target == "all" then
                this.entity:enableplayeruse(player);
            elseif this.target == player.team then
                this.entity:enableplayeruse(player);
            else
                this.entity:disableplayeruse(player);
            end
        -- otherwise it's just player
        else
            if player == this.target then
                this.entity:enableplayeruse(player);
            else
                this.entity:disableplayeruse(player);
            end
        end
    end

    this.update_usable_for_all_player = function ()
        for _, player in pairs(AllPlayers) do
            this.update_usable_for_player(player);
        end
    end

    this.entity:setcursorhint("HINT_NOICON");
    this.entity:sethintstring(this.hint_text);
    this.entity:makeusable();

    this.triggerListener = this.entity:onnotify("trigger", function (player)
        this.use_function(player);
    end);

    this.entity:onnotifyonce("death", function ()
        this.triggerListener:clear();
    end);

    this.deleteSelf = function ()
        for i, usable in pairs(usables) do
            if usable == self then
                table.remove(usables, i);
            end
        end

        this.entity:makeunusable();
        this.triggerListener:clear();
    end

    table.insert(usables, this);
    return this;
end

local updateUsable = function ()
    for _, usable in pairs(usables) do
        usable.update_usable_for_all_player();
    end
end

level:onnotify("joined_team", updateUsable);

require("usables.box_usable");
