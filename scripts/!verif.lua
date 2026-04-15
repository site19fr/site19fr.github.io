local moderators = {"MrGraschat", "Airbus_beluga10","Sans_Argent2","momo907526","Serversidecoolkid","Mr_AllanVOC","Marceaux2011","ThatDudeInThaHood"}

event("chatted", function(data)
    local player, message = data.Value[1], data.Value[2]

    local starting, ending = message:find("^!verif%s*")
    if not ending then return end

    local question = message:sub(ending + 1)

    for _, moderator in ipairs(moderators) do
        runCommand("alert "..moderator.." "..player.." Veut le Serveur Commu")
    end
end)