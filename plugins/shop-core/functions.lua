--- @param player Player|nil
--- @param pointsToIncrement any
function IncrementPlayerCredits(player, pointsToIncrement)
    if not db:IsConnected() then return end
    if not player then return end
    if player:IsFakeClient() then return end
    if not player:IsValid() then return end

    player:SetVar("shop.credits", FetchPlayerCredits(player) + pointsToIncrement)
end

--- @param player Player
function FetchPlayerCredits(player)
    return (player:GetVar("shop.credits") or 0)
end

--- @param player Player
function LoadPlayerData(player)
    if not db:IsConnected() then return end

    db:QueryBuilder():Table("shop"):Select({}):Where("steamid", "=", tostring(player:GetSteamID())):Limit(1):Execute(function (err, result)
            if #err > 0 then
                print("ERROR: " .. err)
                return
            end

            if #result > 0 then
                player:SetVar("shop.credits", result[1].credits)
                player:SetVar("shop.items", result[1].items)
                player:SetVar("shop.items_status", result[1].items_status)
            else
                db:QueryBuilder():Table("shop"):Insert({credits = 0, steamid = tostring(player:GetSteamID())}):Execute(function (err, result)
                    if #err > 0 then
                        print("ERROR LA INSERARE: " .. err)
                    end
                end)
                player:SetVar("shop.credits", 0)
                player:SetVar("shop.items", "[]")
                player:SetVar("shop.items_status", "{}")
            end
        end)
end

--- @param player Player
function SavePlayerData(player)
    if not db:IsConnected() then return end
    if player:IsFakeClient() then return end

    local params = {
        credits = player:GetVar("shop.credits") or 0,
        items = player:GetVar("shop.items") or "[]",
        items_status = player:GetVar("shop.items_status") or "{}",
        steamid = tostring(player:GetSteamID())
    }

    db:QueryBuilder():Table("shop"):Update(params):Where("steamid", "=", tostring(player:GetSteamID())):Execute(function (err, result)
        if #err > 0 then
            print("SHOP ERROR: " .. err)
        end
    end)
end

--- @param player Player
--- @param item_id string
--- @return boolean
function HasItem(player, item_id)
    if player:IsFakeClient() then return false end

    local items = json.decode(player:GetVar("shop.items") or "[]")
    for i=1,#items do
        if items[i] == item_id then
            return true
        end
    end

    return false
end

--- @param player Player
--- @param itemid string
--- @param removeCredits boolean
function GiveShopItem(player, itemid, removeCredits)
    if player:IsFakeClient() then return end
    if HasItem(player, itemid) then return end

    local credits = FetchPlayerCredits(player)
    if credits < ShopItemPrices[itemid] then
        ReplyToCommand(player:GetSlot(), config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.no_credits"):gsub("{REQUIRED_CREDITS}", ShopItemPrices[itemid]))
        return
    end

    local items = json.decode(player:GetVar("shop.items") or "[]")
    table.insert(items, itemid)
    player:SetVar("shop.items", json.encode(items))

    if removeCredits then
        IncrementPlayerCredits(player, -ShopItemPrices[itemid])
    end

    ReplyToCommand(player:GetSlot(), config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.succesfully_bought"):gsub("{ITEM_NAME}", ShopItemNames[itemid]):gsub("{REQUIRED_CREDITS}", ShopItemPrices[itemid]))
end

--- @param player Player
--- @return table
function GetItems(player)
    local items = json.decode(player:GetVar("shop.items") or "[]")
    return items
end

--- @param player Player
--- @param item_id string
--- @return boolean
function HasItemEquipped(player, item_id)
    local item_statuses = json.decode(player:GetVar("shop.items_status") or "{}")
    return (item_statuses[item_id] == true)
end

--- @param player Player
--- @param item_id string
--- @param state boolean
function ChangeItemEquipState(player, item_id, state)
    if player:IsFakeClient() then return end

    local item_statuses = json.decode(player:GetVar("shop.items_status") or "{}")

    local category_id = ShopItemCategories[item_id]
    if ShopCategories[category_id].only_one == true then
        for k in next,item_statuses,nil do
            if ShopItemCategories[k] == category_id then
                item_statuses[k] = false
            end
        end
    end

    item_statuses[item_id] = state
    player:SetVar("shop.items_status", json.encode(item_statuses))

    ReplyToCommand(player:GetSlot(), config:Fetch("shop.core.prefix"), FetchTranslation(state and "shop-core.equip" or "shop-core.unequip"):gsub("{ITEM}", ShopItemNames[item_id]))
    TriggerEvent("shop:core:ItemEquipStateChange", player:GetSlot(), item_id, state)
end

--- @param player Player
--- @param item_id string
--- @param shouldGiveCredits boolean
function RemoveItem(player, item_id, shouldGiveCredits)
    if player:IsFakeClient() then return end
    if not HasItem(player, item_id) then return end

    local items = json.decode(player:GetVar("shop.items") or "[]")
    for i=1,#items do
        if items[i] == item_id then
            ChangeItemEquipState(player, item_id, false)
            table.remove(items, i)
            break
        end
    end
    player:SetVar("shop.items", json.encode(items))

    if shouldGiveCredits then
        IncrementPlayerCredits(player, ShopItemSellPrices[item_id])
    end

    ReplyToCommand(player:GetSlot(), config:Fetch("shop.core.prefix"), FetchTranslation("shop-core.succesfully_sold"):gsub("{ITEM_NAME}", ShopItemNames[item_id]):gsub("{REQUIRED_CREDITS}", ShopItemSellPrices[item_id]))
end
