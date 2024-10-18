export("RegisterItems", function (category_id, category_title_translation, category_items, only_one_item_equipable)
    rawset(ShopCategories, category_id, nil)

    ShopCategories[category_id] = { title = category_title_translation, items = category_items, only_one = only_one_item_equipable }

    for i=1,#category_items do
        rawset(ShopItemNames, category_items[i].id, nil)
        rawset(ShopItemPrices, category_items[i].id, nil)
        rawset(ShopItemSellPrices, category_items[i].id, nil)
        rawset(ShopItemCategories, category_items[i].id, nil)

        ShopItemNames[category_items[i].id] = category_items[i].name
        ShopItemPrices[category_items[i].id] = category_items[i].price
        ShopItemSellPrices[category_items[i].id] = category_items[i].sell_price
        ShopItemCategories[category_items[i].id] = category_id
    end

    GenerateShopMenu()
end)

export("UnregisterItems", function (category_id)
    rawset(ShopCategories, category_id, nil)

    GenerateShopMenu()
end)

export("GetCredits", function (playerid)
    local player = GetPlayer(playerid)
    if not player then return 0 end
    if player:IsFakeClient() then return 0 end

    return FetchPlayerCredits(player)
end)

export("GiveCredits", function (playerid, credits)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if credits < 0 then return end

    IncrementPlayerCredits(player, credits)
end)

export("RemoveCredits", function (playerid, credits)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end
    if credits < 0 then return end

    IncrementPlayerCredits(player, -credits)
end)

export("GiveItem", function (playerid, itemid, shouldRemoveCredits)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end

    GiveShopItem(player, itemid, shouldRemoveCredits)
end)

export("RemoveItem", function (playerid, itemid, shouldGiveCredits)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end

    RemoveItem(player, itemid, shouldGiveCredits)
end)

export("ToggleEquipState", function (playerid, itemid, state)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end

    ChangeItemEquipState(player, itemid, state)
end)

export("HasItemEquipped", function (playerid, itemid)
    local player = GetPlayer(playerid)
    if not player then return false end
    if player:IsFakeClient() then return false end

    return HasItemEquipped(player, itemid)
end)

export("GetItemsFromCategory", function (playerid, category_id)
    local player = GetPlayer(playerid)
    if not player then return {} end
    if player:IsFakeClient() then return {} end

    local items = {}
    local pItems = GetItems(player)

    for i=1,#pItems do
        if ShopItemCategories[pItems[i]] == category_id then
            table.insert(items, pItems[i])
        end
    end

    return items
end)