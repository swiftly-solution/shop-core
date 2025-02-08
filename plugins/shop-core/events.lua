AddEventHandler("OnPluginStart", function (event)
    db = Database("shop")
    if not db:IsConnected() then return end

    config:Create("shop/core", {
        prefix = "[{lime}Swiftly{default}]",
        color = "00a650",
        points = {
            kill = 10,
            death = 5,
            noscope = 25,
            headshot = 15,
            assist = 5
        }
    })

    db:QueryBuilder():Table("shop"):Create({
		steamid = "string|max:128|unique",
		credits = "integer|default:0",
		items = "json|default:[]",
		items_status = "json|default:{}",
	}):Execute(function (err, result)
        if #err > 0 then
            print("ERROR SHOP: " .. err)
        end
    end)


    for i = 1, playermanager:GetPlayerCap() do
        local player = GetPlayer(i - 1)
        if player then
            if not player:IsFakeClient() then
                LoadPlayerData(player)
            end
        end
    end
end)

AddEventHandler("OnAllPluginsLoaded", function (event)
    TriggerEvent("shop:core:RegisterItems")
end)

AddEventHandler("OnPostPlayerTeam", function (event)
    local playerid = event:GetInt("userid")
    local oldTeam = event:GetInt("oldteam")

    if oldTeam ~= Team.None then
        return EventResult.Continue
    end

    local player = GetPlayer(playerid)
    if not player then return EventResult.Continue end

    LoadPlayerData(player)
    return EventResult.Continue
end)

AddEventHandler("OnClientDisconnect", function(event, playerid)
    local player = GetPlayer(playerid)
    if not player then return end
    if player:IsFakeClient() then return end

    SavePlayerData(player)
    return EventResult.Continue
end)

AddEventHandler("OnPlayerDeath", function(event)
    local playerid = event:GetInt("userid")
    local attackerid = event:GetInt("attacker")
    local assisterid = event:GetInt("assister")
    local headshot = event:GetBool("headshot")
    local noscope = event:GetBool("noscope")
    local player = GetPlayer(playerid)
    local attacker = GetPlayer(attackerid)
    local assister = GetPlayer(assisterid)

    if not player or not attacker then return EventResult.Continue end
    if attacker == nil or player == nil then return EventResult.Continue end
    if attackerid == playerid then return EventResult.Continue end

    local attackerpoints = FetchPlayerCredits(attacker)
    local playerpoints = FetchPlayerCredits(player)

    if headshot and attacker then
        IncrementPlayerCredits(attacker, config:Fetch("shop.core.points.headshot"))

        attackerpoints = FetchPlayerCredits(attacker)

        ReplyToCommand(attackerid, config:Fetch("shop.core.prefix"),
            FetchTranslation("shop-core.addcreditsmessage"):gsub("{EXP}", attackerpoints):gsub("{POINTS}",
                config:Fetch("shop.core.points.headshot")):gsub("{CASE}", FetchTranslation("shop-core.headshot")))

        if playerpoints >= config:Fetch("shop.core.points.death") then
            IncrementPlayerCredits(player, -config:Fetch("shop.core.points.death"))

            playerpoints = FetchPlayerCredits(player)

            ReplyToCommand(playerid, config:Fetch("shop.core.prefix"),
                FetchTranslation("shop-core.removecreditsmessage"):gsub("{EXP}", playerpoints):gsub("{POINTS}",
                    config:Fetch("shop.core.points.death")):gsub("{CASE}", FetchTranslation("shop-core.death")))
        end
    elseif noscope and attacker then
        IncrementPlayerCredits(attacker, config:Fetch("shop.core.points.noscope"))

        attackerpoints = FetchPlayerCredits(attacker)

        ReplyToCommand(attackerid, config:Fetch("shop.core.prefix"),
            FetchTranslation("shop-core.addcreditsmessage"):gsub("{EXP}", attackerpoints):gsub("{POINTS}",
                config:Fetch("shop.core.points.noscope")):gsub("{CASE}", FetchTranslation("shop-core.noscope")))

        if playerpoints >= config:Fetch("shop.core.points.death") then
            IncrementPlayerCredits(player, -config:Fetch("shop.core.points.death"))

            playerpoints = FetchPlayerCredits(player)

            ReplyToCommand(playerid, config:Fetch("shop.core.prefix"),
                FetchTranslation("shop-core.removecreditsmessage"):gsub("{EXP}", playerpoints):gsub("{POINTS}",
                    config:Fetch("shop.core.points.death")):gsub("{CASE}", FetchTranslation("shop-core.death")))
        end
    elseif attacker then
        IncrementPlayerCredits(attacker, config:Fetch("shop.core.points.kill"))

        attackerpoints = FetchPlayerCredits(attacker)

        ReplyToCommand(attackerid, config:Fetch("shop.core.prefix"),
            FetchTranslation("shop-core.addcreditsmessage"):gsub("{EXP}", attackerpoints):gsub("{POINTS}",
                config:Fetch("shop.core.points.kill")):gsub("{CASE}", FetchTranslation("shop-core.kill")))

        if playerpoints >= config:Fetch("shop.core.points.death") then
            IncrementPlayerCredits(player, -config:Fetch("shop.core.points.death"))

            playerpoints = FetchPlayerCredits(player)

            ReplyToCommand(playerid, config:Fetch("shop.core.prefix"),
                FetchTranslation("shop-core.removecreditsmessage"):gsub("{EXP}", playerpoints):gsub("{POINTS}",
                    config:Fetch("shop.core.points.death")):gsub("{CASE}", FetchTranslation("shop-core.death")))
        end
    end

    if assister then
        IncrementPlayerCredits(assister, config:Fetch("shop.core.points.assist"))

        local assisterpoints = FetchPlayerCredits(assister)

        ReplyToCommand(attackerid, config:Fetch("shop.core.prefix"),
            FetchTranslation("shop-core.addcreditsmessage"):gsub("{EXP}", assisterpoints):gsub("{POINTS}",
                config:Fetch("shop.core.points.assist")):gsub("{CASE}", FetchTranslation("shop-core.assist")))
    end
end)

SetTimer(10000, function ()
    for i=1,playermanager:GetPlayerCap() do
        local player = GetPlayer(i-1)
        if player and player:IsValid() then
            SavePlayerData(player)
        end
    end
end)