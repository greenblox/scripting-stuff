-- moved from pastebin to github cuz the syntax highlighting is hot here (https://pastebin.com/frf0GYdp)
-- discord: greenblocks#9545
-- please ignore the inconsistency for spacing at the beginning of comments, thanks!
--~~Submitted for HD application (primary use) and is also~~ being used to show what I can be capable of relating to scripting:
--Intended to be used as something that shows that I know what the code is and how it works.

--Trees and terrain that change during seasons, winter example:
for i,v in pairs(game.Workspace:GetDescendants()) --[[ gets descendants of the game and then checks their name --]] do if v.Name == "TreeMeshSeasonal" then v.Color = Color3.fromRGB(225, 225, 225) v.Material = Enum.Material.Sand end end --All of the tree parts that needed changing were named TreeMeshSeasonal so I could loop through all of them with ease. It makes them white and makes their material sand.
workspace.Terrain:ReplaceMaterial(Region3.new(Vector3.new(-3072, 15, -3072), Vector3.new(3072, 95, 3072)):ExpandToGrid(4), 4, Enum.Material.Grass, Enum.Material.Snow) -- Makes all grass into snow in the entirety of the map (which was quite big as you can tell)

--Money System using DataStore2:
local DataStore2 = require(script.Parent:WaitForChild("DataStore2")) -- the datastore2 module is in the script's parent aka serverscriptservice in this case
local MoneyData = game:GetService("ServerStorage"):WaitForChild("MoneyData") -- waits for the money data folder in serverstorage
DataStore2.Combine("DATA", "wallet") -- some setup for the datastore
DataStore2.Combine("DATA", "bank") -- some setup for the datastore

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("FetchMoneyData") -- waits for the FetchMoneyData remote in replicatedstorage
Remote.OnServerInvoke = function(plr, location) -- ties the OnServerInvoke of the remote to a function that asks for the arguments plr and location
	if location == "Wallet" then -- check for what "location" aka currency type they're requesting
		local PlrData = MoneyData:FindFirstChild(plr.Name) -- gets their data from the moneydata folder
		if not PlrData then return "no_data" end -- if there is no data, they haven't loaded it yet
		local Wallet = PlrData:FindFirstChild("Wallet") -- gets their wallet info
		if not Wallet then return "no_data" end -- if that doesnt exist either, return no_data once again
		return Wallet.Value -- finally return wallet.value if none of the above requirements are violated
	elseif location == "Bank" then -- checks if the location is bank
		local PlrData = MoneyData:FindFirstChild(plr.Name) -- gets player data from moneydata
		if not PlrData then return "no_data" end -- if it doesnt exist return no_data
		local Bank = PlrData:FindFirstChild("Bank") -- get their bank balance intvalue
		if not Bank then return "no_data" end -- if it doesnt exist return no_data
		return Bank.Value -- finally return bank.value if none of the above requirements are violated
	else
		return "invalid_location" -- return invalid_location if somehow they didnt supply proper information
	end
end

local function playerAdded(plr)
	local WalletStore = DataStore2("wallet", plr) -- gets the datastore2
	local BankStore = DataStore2("bank", plr) -- gets the datastore2
	local Wallet = Instance.new("NumberValue") -- creates a wallet value
	Wallet.Name = "Wallet"
	Wallet.Parent = MoneyData
	Wallet.Value = WalletStore:Get(0) or 0 -- sets its value
	local Bank = Instance.new("NumberValue") -- creates a bank value
	Bank.Name = "Bank"
	Bank.Parent = MoneyData
	Bank.Value = BankStore:Get(450) or 0 -- sets its value
end

for i,v in pairs(game.Players:GetPlayers()) do
	spawn(function() playerAdded(v) end) -- gets all existing players and then sends them through playerAdded
end

game.Players.PlayerAdded:Connect(playerAdded) -- Waits for datastore 2 to exist so it connects to this Roblox Script Signal after scanning through all players that wouldn't have been registered considering that it may take some time for the module to become a child of serverscriptservice, and even if it isn't, it's considered a good practice to me since sometimes I may forget this and wonder why it registers players only after a certain amount of time!

--The player starts with 450 cash in their bank and 0 in their wallet. The player can request either their wallet or bank amounts with game.ReplicatedStorage.FetchMoneyData.

--A small system to simulate VIP servers by just creating VIP servers and allowing the player to teleport to them if enabled by me:
local TS = game:GetService("TeleportService") -- gets teleportservice
local servers = {TS:ReserveServer(game.PlaceId), TS:ReserveServer(game.PlaceId), TS:ReserveServer(game.PlaceId), TS:ReserveServer(game.PlaceId), TS:ReserveServer(game.PlaceId)} -- creates 4 reserved servers
local Players = game:GetService("Players") -- gets players, the service
local PrivateServers = false -- bool that is a toggle if players can tp to reserved servers (special events)
local Prefix = ":" -- prefix

local function Joined(plr)
	plr.Chatted:Connect(function(msg)
		msg = msg:lower():split(" ") -- splits message by " " into a table
		local code = tonumber(msg[2]) -- gets the server number
		if msg[1] == Prefix.."reservedserver" then -- checks for the message
			if PrivateServers or plr.Name == "greeenblox" then -- permissions
				TS:TeleportToPrivateServer(game.PlaceId,servers[code],{plr}) -- teleports them
			end
		elseif msg[1] == Prefix.."allowreservedservers" then -- checks for the message
			if plr.Name == "greeenblox" then -- permissions
				if msg[2] == "on" or msg[2] == "yes" or msg[2] == "true" then -- on or off
					PrivateServers = true -- on
				elseif msg[2] == "off" or msg[2] == "no" or msg[2] == "false" then -- on or off
					PrivateServers = false -- off
				end
			end
		end
	end)
end
--creates new 4 servers per main game server and allows me to toggle them on and off by running the correct commands. also players have a command to join them during events!

--A staff door that uses PhysicsService and collision groups:
local phs = game:GetService("PhysicsService")
phs:CreateCollisionGroup("a") -- makes a collision group
phs:CreateCollisionGroup("b") -- makes a collision group
phs:CollisionGroupSetCollidable("a", "b", false) -- sets one not collidable
for i,v in pairs(script.Parent:GetChildren()) do -- gets children of the parent (the door's main model)
	if v:IsA("BasePart") then -- checks if its a basepart
		phs:SetPartCollisionGroup(v, "a") -- sets the collision group that can collide
	end
end

local function plrAdded(plr) -- general playeradded stuff
	local function charAdded(char) -- char added
		if plr.Team == game:GetService("Teams"):WaitForChild("Park Rangers") then
			wait(1)
			for i,v in pairs(char:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("MeshPart") then
					phs:SetPartCollisionGroup(v, "b") -- sets collision groups after 1 second
				end
			end
		end
	end
	
-- char added stuff just like the player added stuff

	if plr.Character then
		spawn(function() charAdded(plr.Character) end)
	end
	
	plr.CharacterAdded:Connect(charAdded)
end

for i,v in pairs(game:GetService("Players"):GetPlayers()) do
	spawn(function()
		plrAdded(v)
	end)
end

game:GetService("Players").PlayerAdded:Connect(plrAdded)
--quite self explanatory, creates 2 collision groups, gives Park Rangers the ability to enter, while other people cannot.

--Simple GUI system used and sold in my basic mannequin:
local sCon -- defines a nil variable
local pCon -- defines a nil variable

game:GetService("ReplicatedStorage"):WaitForChild("ShopInfoClient").OnClientEvent:Connect(function(shirt, pants) -- connects on the client to ReplicatedStorage.ShopInfoClient
	script.Parent.Parent.Visible = true -- makes the frame visible
-- checks if the previous mousebutton1click connections still exist so we can disconnect them so that it doesnt prompt us with multiple things after clicking multiple buy buttons
	if sCon then
		sCon:Disconnect()
		sCon = nil
	end
	if pCon then
		pCon:Disconnect()
		pCon = nil
	end
	if shirt <= 0 then -- for example if its only a shirt or pants or even a full set of clothing, it'll adjust since there is a uilistlayout in it
		script.Parent.Shirt.Visible = false
	else
		script.Parent.Shirt.Visible = true
	end
	
	if pants <= 0 then
		script.Parent.Pants.Visible = false
	else
		script.Parent.Pants.Visible = true
	end
	
	-- connects to the functions, self explanatory
	sCon = script.Parent.Shirt.MouseButton1Click:Connect(function()
		game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, shirt)
		print("shirt "..shirt) -- debug
	end)
	pCon = script.Parent.Pants.MouseButton1Click:Connect(function()
		game:GetService("MarketplaceService"):PromptPurchase(game.Players.LocalPlayer, pants)
		print("pants "..pants) -- debug
	end)
end)
--Basically, it will open if anybody clicks on a mannequin

-- Some more examples that I feel too lazy to comment too much
local keys = {Soldiers = "soldiers_"..reset, --[[SoldierMax = "maxsoldiers_"..reset, ]]Currency = "currency_"..reset, --[[Level = "level_"..reset, ]]XP = "XPStore_"..reset} -- creates a dict of keys
for i,v in pairs(keys) do -- loop
	DataStore2.Combine(v) -- combines them (refer to the DataStore2 API https://kampfkarren.github.io/Roblox/api/)
end
local function getData(plr)
	local Data = {} -- setting up a 
	for i,v in pairs(keys) do -- loops through keys and values
		Data[i] = DataStore2(v, plr) -- as you can tell, it will register it into the Data table which holds keys and then their datastore equivalent
	end
	return Data -- returns the Data table
end
-- related to the above code as it uses it  to function here
local function calculateLevel(xp)
	return 0.5 + math.sqrt(1 + 8*xp/t) -- basic xp system. xp = xp, t = the threshold
end
local function getLevel(plr, Data, xp)
	if not Data then
		Data = getData(plr)
	end
	if not xp then
		xp = Data.XP:Get(0)
	end
	local level = calculateLevel(xp)
	return math.floor(level) -- uses math.floor on it to simplify it instead of creating a long number
end
local function xpToNextLevel(level, xp)
	local objective = level+1 -- creates an objective
	local i = xp -- defines what i currently is
	local success
	repeat
		i = i + 1 -- goes up by one each time
		--print(calculateLevel(i))
		if math.floor(calculateLevel(i)) == objective then success = true end -- now i could just put this statement in place of success but I was using this print above as a debug and stuff, checks if it is equal to the objective after calculating the level using the i variable
		--wait(.1)
	until success
	return i -- returns that amount of xp for this nice result (Level x (y/z) Warrior, https://i.imgur.com/gDsto3K.png)
end

-- there is lots more of this script but I'm not trying to leak an upcoming game's (the one in development within Vanity Studios) serversided source code so yeah

--[[ I don't think too much more is needed, but I may be wrong. Lots of my work I like to keep private in a way and a lot of my work is scattered around several places.

Mannequin (used in these code examples): https://www.roblox.com/games/5779901372/Mannequin
SCPF game: https://www.roblox.com/games/4939558958/SCP-Area-65
Lakeside City, a game that is in WIP (used in these code examples): https://www.roblox.com/games/5443820424/Lakeside-City

A commission I completed, basically just a clickdetector morph system: https://www.roblox.com/games/5806019116/Badges-Test
Another commission where the user scammed me, obby checkpoint system: https://www.roblox.com/games/5806231736/Checkpoints

And then a website that hosts more work: https://portfolio.steveraft.repl.co/ Not sure if the website is allowed to be used as work since it's external, but hopefully everything before was enough!
--]]
