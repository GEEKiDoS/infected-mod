table.insert(PlayerSpawnedHooks, function (player)
    -- Human
    if player.team == "allies" then
        game:ontimeout(function ()
            player:takeallweapons();
            player:clearperks();
        end, 100);

        game:ontimeout(function ()
            local humanStartWeapon = "iw6_p226_mp";

            player:giveweapon(humanStartWeapon);
            player:givemaxammo(humanStartWeapon);

            local humanPerks = {
                "specialty_holdbreath",
                "specialty_holdbreathwhileads",
                "specialty_fastermelee",
                "specialty_bulletaccuracy",
                "specialty_longerrange",
                "specialty_fastoffhand",
                "specialty_reducedsway",
            };
    
            local humanEquips = {
                "c4_mp",
                "trophy_mp"
            };
    
            for _, perk in ipairs(humanPerks) do
                player:setperk(perk, true, false);
            end
    
            for _, equip in ipairs(humanEquips) do
                player:setperk(equip, false, true);
                player:giveweapon(equip);
                player:givemaxammo(equip);
            end
    
            player:switchtoweaponimmediate(humanStartWeapon);
        end, 400);
    -- Infected
    elseif player.team == "axis" then
        game:ontimeout(function ()
            player:takeallweapons();
            player:clearperks();
        end, 100);
        
        game:ontimeout(function ()
            local infectedStartWeapon = "iw6_knifeonly_mp";

            player:giveweapon(infectedStartWeapon);
            player:givemaxammo(infectedStartWeapon);

            player:switchtoweaponimmediate(infectedStartWeapon);

            local infectedPerks = {
                "specialty_holdbreath",
                "specialty_holdbreathwhileads",
                "specialty_fastermelee",
                "specialty_bulletaccuracy",
                "specialty_longerrange",
                "specialty_fastoffhand",
                "specialty_reducedsway",
            };

            for _, perk in ipairs(infectedPerks) do
                player:setperk(perk, true, false);
            end
            
            player:setperk("specialty_tacticalinsertion", false, true);
            player:setactionslot(3, "", "flare_mp")
            player:giveweapon("flare_mp");
            player:givemaxammo("flare_mp");
        end, 400);
    end
end);

game:precacheitem("flare_mp");
