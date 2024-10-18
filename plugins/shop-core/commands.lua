commands:Register("credits", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end

    local credits = FetchPlayerCredits(player)
    ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.credits"):gsub("{CREDITS}", credits))
end)

commands:Register("shop", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end

    player:HideMenu()
    player:ShowMenu("shopmenu")
end)

commands:Register("openshopcategory", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 1 then return end

    local category = args[1]

    local category_data = ShopCategories[category]
    if not category_data then return end

    local options = {
        { FetchTranslation("shop-core.menu.mainmenu"), "sw_shop" }
    }
    for i=1,#category_data.items do
        table.insert(options, { "["..(HasItem(player, category_data.items[i].id) and "✔️" or "❌").."] " .. category_data.items[i].name .. " ("..category_data.items[i].price..")", "sw_buyitemcheck \""..category.."\" \""..category_data.items[i].id.."\"" })
    end

    local menuid = "shopmenu_"..category.."_"..(GetTime())
    menus:RegisterTemporary(menuid, FetchTranslation(category_data.title), config:Fetch("shop.core.color"), options)

    player:HideMenu()
    player:ShowMenu(menuid)
end)

commands:Register("buyitemcheck", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 2 then return end

    local category = args[1]
    local itemid = args[2]

    local category_data = ShopCategories[category]
    if not category_data then return end

    if HasItem(player, itemid) then
        return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.already_own"):gsub("{ITEM}", FetchTranslation(category_data.title) .. " - " .. ShopItemNames[itemid]))
    end

    local options = {
        { FetchTranslation("shop-core.confirmation_text"):gsub("{CREDITS}", ShopItemPrices[itemid]):gsub("{COLOR}", config:Fetch("shop.core.color")), "" },
        { FetchTranslation("shop-core.menu.yes"), "sw_buyitem \""..category.."\" \""..itemid.."\"" },
        { FetchTranslation("shop-core.menu.no"), "sw_hideshopitembuy" }
    }

    local menuid = "shopmenu_"..category.."_buy_"..(GetTime())
    menus:RegisterTemporary(menuid, FetchTranslation(category_data.title) .. " - " .. ShopItemNames[itemid], config:Fetch("shop.core.color"), options)

    player:HideMenu()
    player:ShowMenu(menuid)
end)

commands:Register("buyitem", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 2 then return end

    local category = args[1]
    local itemid = args[2]

    local category_data = ShopCategories[category]
    if not category_data then return end

    if HasItem(player, itemid) then
        return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.already_own"):gsub("{ITEM}", FetchTranslation(category_data.title) .. " - " .. ShopItemNames[itemid]))
    end

    GiveShopItem(player, itemid, true)
    player:HideMenu()
end)

commands:Register("hideshopitembuy", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end

    player:HideMenu()
end)

commands:Register("items", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end

    local options = {}
    local registered = {}
    local items = GetItems(player)

    for i=1,#items do
        local category_id = ShopItemCategories[items[i]]
        if not registered[category_id] then
            registered[category_id] = true
            table.insert(options, { FetchTranslation(ShopCategories[category_id].title), "sw_openitems \""..category_id.."\"" })
        end
    end

    if #options <= 0 then return end

    local menuid = "shopmenu_items_"..(GetTime())
    menus:RegisterTemporary(menuid, FetchTranslation("shop-core.menu.items"), config:Fetch("shop.core.color"), options)

    player:HideMenu()
    player:ShowMenu(menuid)
end)

commands:Register("openitems", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 1 then return end

    local category_id = args[1]
    local options = {}
    local items = GetItems(player)

    for i=1,#items do
        local cat = ShopItemCategories[items[i]]
        if category_id == cat then
            table.insert(options, { ShopItemNames[items[i]], "sw_openitemsmenu \""..category_id.."\" \""..items[i].."\"" })
        end
    end

    if #options <= 0 then return end

    local menuid = "shopmenu_openitems_"..(GetTime())
    menus:RegisterTemporary(menuid, FetchTranslation("shop-core.menu.items") .. " - " .. FetchTranslation(ShopCategories[category_id].title), config:Fetch("shop.core.color"), options)

    player:HideMenu()
    player:ShowMenu(menuid)
end)

commands:Register("openitemsmenu", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 2 then return end

    local category_id = args[1]
    local item_id = args[2]
    if not HasItem(player, item_id) then return end

    local options = {
        { FetchTranslation(HasItemEquipped(player, item_id) and "shop-core.menu.unequip" or "shop-core.menu.equip"), "sw_toggleequipstate \""..item_id.."\"" },
        { FetchTranslation("shop-core.menu.sell") .. " ("..ShopItemSellPrices[item_id]..")", "sw_sellitemcheck \""..item_id.."\"" }
    }

    local menuid = "shopmenu_itemsmenu_"..(GetTime())
    menus:RegisterTemporary(menuid, FetchTranslation(ShopCategories[category_id].title) .. " - " .. ShopItemNames[item_id], config:Fetch("shop.core.color"), options)

    player:HideMenu()
    player:ShowMenu(menuid)
end)

commands:Register("toggleequipstate", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 1 then return end

    local item_id = args[1]
    if not HasItem(player, item_id) then return end

    ChangeItemEquipState(player, item_id, not HasItemEquipped(player, item_id))
    player:ExecuteCommand("sw_openitemsmenu \""..ShopItemCategories[item_id].."\" \""..item_id.."\"")
end)

commands:Register("sellitemcheck", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 1 then return end

    local item_id = args[1]
    if not HasItem(player, item_id) then return end

    local options = {
        { FetchTranslation("shop-core.sell_confirmation_text"):gsub("{CREDITS}", ShopItemSellPrices[item_id]):gsub("{COLOR}", config:Fetch("shop.core.color")), "" },
        { FetchTranslation("shop-core.menu.yes"), "sw_sellitem \""..item_id.."\"" },
        { FetchTranslation("shop-core.menu.no"), "sw_hideshopitembuy" }
    }

    local menuid = "shopmenu_"..ShopItemCategories[item_id].."_sell_"..(GetTime())
    menus:RegisterTemporary(menuid, FetchTranslation(ShopCategories[ShopItemCategories[item_id]].title) .. " - " .. ShopItemNames[item_id], config:Fetch("shop.core.color"), options)

    player:HideMenu()
    player:ShowMenu(menuid)
end)

commands:Register("sellitem", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 1 then return end

    local item_id = args[1]
    if not HasItem(player, item_id) then return end

    RemoveItem(player, item_id, true)
    player:HideMenu()
end)

commands:Register("givecredits", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end

    if not exports["admins"]:HasFlags(playerid, config:Fetch("shop.core.adminflag")) then
        return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.nopermissions"))
    end

    if argc ~= 2 then return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.givecredits.syntax")) end

    local target = args[1]
    local players = FindPlayersByTarget(target, false)

    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("shop.prefix"), FetchTranslation("shop-core.invalid_player"))
    end

    local credits = tonumber(args[2])
    if not credits then
        return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), "Invalid number of credits.")
    end

    for i =1, #players do
        local targetPlayer = players[i]
        IncrementPlayerCredits(targetPlayer, credits)
        ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.gave_credits"):gsub("{CREDITS}", credits):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName))
    end

end)

commands:Register("removecredits", function (playerid, args, argc, silent, prefix)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end
    if argc ~= 2 then return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.removecredits.syntax")) end

    if not exports["admins"]:HasFlags(playerid, config:Fetch("shop.core.adminflag")) then
        return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.nopermissions"))
    end

    local target = args[1]
    local players = FindPlayersByTarget(target, false)

    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("shop.prefix"), FetchTranslation("shop-core.invalid_player"))
    end

    local credits = tonumber(args[2])
    if not credits then
        return ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), "Invalid number of credits.")
    end

    for i =1, #players do
        local targetPlayer = players[i]
        IncrementPlayerCredits(targetPlayer, -credits)
        ReplyToCommand(playerid, config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.removed_credits"):gsub("{CREDITS}", credits):gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName))
    end

end)