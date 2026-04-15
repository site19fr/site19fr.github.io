--Stamina Script by officialYFG, Experimental; Expect bugs.
--By using this script you agree that you will not take credit for my work or this script.

--If you do use this for your servers, I'd love to see how this could help with realism.

local maxstamina = 6 --The max amount of stamina you can have.
local fullregen = 4 --How much stamina you must have to sprint again after losing all of it.
local gainfromwalking = 0.5 --How much stamina you gain while walking.
local gainfromstanding = 1 --How much stamina you gain from standing still.

local outofstaminasound = "rbxassetid://6814463121" --The Out of Stamina sound ID.
local outofstaminavolume = 0.03 --How loud the Out of Stamins sound is.

local debugmode = false --Debug mode, advanced feature.

--END OF CUSTOMIZABLE VARIABLES, DO NOT EDIT BEYOND HERE.

local updaterate = 1

local folder = f("KeyFolder")
if not folder then
local folder = Instance.new("Folder")
f(folder)
folder.Name = "KeyFolder"
end

local prompts = {}

for i,v in ipairs(folder:GetChildren()) do
v:Destroy()
end

local function updatepos(part,plr)
local pos = getPlayerPosition(plr)
part.Position = pos.Position + pos.LookVector * 4.5

task.wait(0.01)
task.spawn(updatepos,part,plr)
end

local function createprompt(plr)
local part = Instance.new("Part",folder)
local pos = getPlayerPosition(plr)
part.Size = Vector3.new(0.1,0.1,0.1)
part.Position = pos.Position + pos.LookVector * 4.5
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Anchored = true
part.Transparency = 1
part.Name = plr

local prompt = Instance.new("ProximityPrompt",part)
prompt.KeyboardKeyCode = Enum.KeyCode.LeftShift
prompt.HoldDuration = 9999
prompt.ObjectText = ""
prompt.ActionText = ""
prompt.RequiresLineOfSight = false
prompt.UIOffset = Vector2.new(math.huge,math.huge)
prompt.Name = plr
prompt.Enabled = false
prompt.MaxActivationDistance = 7

table.insert(prompts,prompt)

task.spawn(updatepos,part,plr)
end

local function toggleprompt(plr, val)
for i,v in ipairs(prompts) do
if v.Name == plr then
v.Enabled = val

if val == true then
local orghealth = getPlayerHealth(plr)
setPlayerHealth(plr,10)
task.wait()
setPlayerHealth(plr,orghealth)

local sound = Instance.new("Sound")
sound.SoundId = outofstaminasound
sound.Volume = outofstaminavolume
sound.RollOffMaxDistance = 55
sound.RollOffMinDistance = 22.5
sound.RollOffMode = Enum.RollOffMode.Linear

local stop, setspeed = playSound(sound,plr,true)
end
end
end
end

local function getspeed(plr)
local startpos = getPlayerPosition(plr).Position
task.wait(0.1)
local endpos = getPlayerPosition(plr).Position

local dist = (endpos - startpos).Magnitude
local speed = dist / 0.1
return speed
end

local function setstamina(plr, stamina)
while task.wait(updaterate) do
local speed = getspeed(plr)

if speed > 18 and stamina > 0 then
stamina = stamina - 1
elseif speed < 2 and stamina < maxstamina then
stamina = stamina + gainfromstanding
elseif speed < 18 and stamina < maxstamina then
stamina = stamina + gainfromwalking
end

if stamina > maxstamina then
stamina = maxstamina
end

if stamina < 0 then
stamina = 0
end

if stamina == 0 then
task.spawn(toggleprompt,plr,true)
elseif stamina > fullregen then
task.spawn(toggleprompt,plr,false)
end

task.wait()
if debugmode then announce(plr,"[DEBUG] Stamina Left: "..stamina) end
end
end

event("joined",function(data)
local plr = data.Value

createprompt(plr)
task.spawn(setstamina,plr,maxstamina)
end)

event("left",function(data)
local plr = data.Value

for i,v in ipairs(prompts) do
if v.Name == plr then
v:Destroy()
end
end
end)

for i,v in ipairs(getPlayers()) do
createprompt(v)
task.spawn(setstamina,v,maxstamina)
end