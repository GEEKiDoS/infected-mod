BoxUsable = {};

function BoxUsable:new(origin, angles, type, issolid)
    local box = SpawnBox(origin, angles, type, issolid);
    local baseUsable = BaseUsable:new(box);
    
    return baseUsable;
end

require("usables.boxes.gambler");
