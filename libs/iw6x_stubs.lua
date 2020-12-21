if game == nil then
    game = {
        getdvar = function(_, dvarname) end,
        getdvarint = function(_, dvarname) end,
        getent = function(_, value, key) end,
        newhudelem = function(_) end,
        objectiveicon = function(_, objId, icon) end,
        objectiveposition = function(_, objId, position) end,
        objectivestate = function(_, objId, state) end,
        oninterval = function(_, func, time) end,
        precachematerial = function(_, materialName) end,
        precachemodel = function(_, modelName) end,
        setdvarifuninitialized = function(_, dvarname, value) end,
        spawn = function(_, class, position, flags, radius, height) end,
        vectortoangles = function(_, fowardvector) end,
        distance = function(_, a, b) end,
        distancesquared = function(_, a, b) end,
        distance2d = function(_, a, b) end,
        distance2dsquared = function(_, a, b) end,
    }
end

if vector == nil then
    vector = {
        new = function (_,x,y,z) end,
        x = 0.0,
        y = 0.0,
        z = 0.0
    }
end

if level == nil then
    level = {
        onnotify = function (_, event, func) end,
        onnotifyonce = function (_, event, func) end
    }
end