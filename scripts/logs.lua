--'Discord Logging Script' by officialYFG, All Rights Reserved. ©
--If you Find any Issues with the Script, please Speak in the Distribution Thread.

--IMPORTANT: Do NOT Share your Token or URL with ANYONE, they can Easily Gain—
--—Access to your Application and get you banned. Please be careful.

local dateconfig = {
["Date Formatting"] = true, --Whether the Script Uses AM PM Formatting or not.
["Includes Seconds"] = true -- Whether or Not the Date Includes the Seconds.
}

local messageconfig = {
["Enabled"] = true, -- Whether or Not this Listener is Enabled, this is Recommended 'true'.
["Message"] = "**Message** `[PLAYER]` à dit: **[MESSAGE]** à `[DATE]`.", -- The Message the Attachment Sends.

["Message Batching"] = true, -- Whether or not Messages are Batched to Avoid Rate Limits.
["Batch Wait"] = 5, -- The Amount Of Time To Wait Between Sending Batches, in Seconds.
["Batch Size"] = 50, -- The Maximum Amount Of Messages In Each Batch Message.

["Ignore Formatting"] = false, -- Whether or not the Script Ignores Discord Formatting.
}

local deathconfig = {
["Enabled"] = true, -- Whether or Not this Listener is Enabled, this is Recommended 'false'.
["Message"] = "**Mort** `[PLAYER]` est mort." -- The Message the Attachment Sends.
}

local killconfig = {
["Enabled"] = true, -- Whether or Not this Listener is Enabled, this is Recommended 'false'.
["Message"] = "**Kill** `[VICTIM]` a été tué par `[KILLER]`." -- The Message the Attachment Sends.
}

local joinconfig = {
["Enabled"] = true, -- Whether or Not this Listener is Enabled, this is Recommended 'true'.
["Message"] = "**Join** `[PLAYER]` a rejoint le serveur à `[DATE]`." -- The Message the Attachment Sends.
}

local leaveconfig = {
["Enabled"] = true, -- Whether or Not this Listener is Enabled, this is Recommended 'true'.
["Message"] = "**Leave** `[PLAYER]` a quitté le serveur à `[DATE]`." -- The Message the Attachment Sends.
}

local interactionconfig = {
["Enabled"] = true, -- Whether or Not this Listener is Enabled, this is Recommended 'true'.
["Message"] = "**Interaction** `[PLAYER]` à intéragi avec `**[PART]**`." -- The Message the Attachment Sends.
}

--End Of Script Configuration, it is Unrecommended to Edit Beyond Here.
--For Additional Help, Feel Free to Speak in the Distribution Thread.

local function sendmessage(msg)
local data = {["content"] = msg}

if config["Token"]:sub(8) == "https://" then
local response = http(config["Token"],
"POST",
{["Content-Type"] = "application/json"}
,jsonEncode(data)
)
else
local response = http("https://discord.com/api/v10/channels/"..config["Channel ID"].."/messages",
"POST",
{["Content-Type"] = "application/json",["Authorization"] = "Bot "..config["Token"]}
,jsonEncode(data)
)
end
end

local currentmessages = {}

local function runmessagebatches()
if #currentmessages >= 1 then
local batchedmessage = ""
local purgecount = 0

for i,msg in ipairs(currentmessages) do
if #batchedmessage >= 2000 then break end
batchedmessage = batchedmessage.."\n"..msg
purgecount = i
end

for i = 1,purgecount do
table.remove(currentmessages,1)
end

task.spawn(sendmessage,batchedmessage)
end

task.wait(messageconfig["Batch Wait"])
task.spawn(runmessagebatches)
end

local function getcurrentdate()
local date = os.date("%I:%M:%S %p")

if not dateconfig["Includes Seconds"] then
date = os.date("%I:%M %p")
end

if not dateconfig["Date Formatting"] then
date = os.date("%H:%M:%S")

if not dateconfig["Includes Seconds"] then
date = os.date("%H:%M")
end
end

return date
end

event("chatted",function(data)
if not messageconfig["Enabled"] then return end

local plr = data.Value[1]
local msg = data.Value[2]

local newmessage = messageconfig["Message"]
newmessage = newmessage:gsub("%[PLAYER%]",plr)
newmessage = newmessage:gsub("%[MESSAGE%]",msg)

local when = getcurrentdate()
newmessage = newmessage:gsub("%[DATE%]",when.." UTC")

if messageconfig["Ignore Formatting"] == true then
newmessage = newmessage:gsub("[%*_%`|]","")
end

if messageconfig["Message Batching"] then
table.insert(currentmessages,newmessage)
else
task.spawn(sendmessage,newmessage)
end
end)

if messageconfig["Message Batching"] then
task.spawn(runmessagebatches)
end

event("death",function(data)
if not deathconfig["Enabled"] then return end

local plr = data.Value

local newmessage = deathconfig["Message"]
newmessage = newmessage:gsub("%[PLAYER%]",plr)

local when = getcurrentdate()
newmessage = newmessage:gsub("%[DATE%]",when.." UTC")

task.spawn(sendmessage,newmessage)
end)

event("kill",function(data)
if not killconfig["Enabled"] then return end

local killer = data.Value[1]
local victim = data.Value[2]

local newmessage = deathconfig["Message"]
newmessage = newmessage:gsub("%[KILLER%]",killer)
newmessage = newmessage:gsub("%[PLAYER%]",killer)
newmessage = newmessage:gsub("%[VICTIM%]",victim)

local when = getcurrentdate()
newmessage = newmessage:gsub("%[DATE%]",when.." UTC")

task.spawn(sendmessage,newmessage)
end)

event("joined",function(data)
if not joinconfig["Enabled"] then return end

local plr = data.Value

local newmessage = joinconfig["Message"]
newmessage = newmessage:gsub("%[PLAYER%]",plr)

local when = getcurrentdate()
newmessage = newmessage:gsub("%[DATE%]",when.." UTC")

task.spawn(sendmessage,newmessage)
end)

event("left",function(data)
if not leaveconfig["Enabled"] then return end

local plr = data.Value

local newmessage =  leaveconfig["Message"]
newmessage = newmessage:gsub("%[PLAYER%]",plr)

local when = getcurrentdate()
newmessage = newmessage:gsub("%[DATE%]",when.." UTC")

task.spawn(sendmessage,newmessage)
end)

event("interaction",function(data)
if not interactionconfig["Enabled"] then return end

local plr = data.Value[1]
local part = data.Value[2]

local newmessage =  interactionconfig["Message"]
newmessage = newmessage:gsub("%[PLAYER%]",plr)
newmessage = newmessage:gsub("%[PART%]",part)

local when = getcurrentdate()
newmessage = newmessage:gsub("%[DATE%]",when.." UTC")

task.spawn(sendmessage,newmessage)
end)