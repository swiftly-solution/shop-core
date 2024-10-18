function GenerateShopMenu()
    local options = {}
    for k,v in next,ShopCategories,nil do
        table.insert(options, { FetchTranslation(v.title), "sw_openshopcategory \""..k.."\"" })
    end

    menus:Unregister("shopmenu")
    menus:Register("shopmenu", FetchTranslation("shop-core.menu.title"), config:Fetch("shop.core.color"), options)
end