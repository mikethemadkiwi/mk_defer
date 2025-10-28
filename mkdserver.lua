math.randomseed(os.time())
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- local maxPlayerCap = GetConvarInt('sv_maxclients', 9) -- set this to YOUR city max player cap. change from maxcap to -1 to simulate full.
local maxPlayerCap = 9
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
local QueueStaff = {}
local QueuePrio = {}
local QueueClient = {}
local OnlineClient = {}
local TermsCard = json.decode(LoadResourceFile(GetCurrentResourceName(), "tos.json"))
local TextCard = json.decode(LoadResourceFile(GetCurrentResourceName(), "text.json"))
local QueueCard = json.decode(LoadResourceFile(GetCurrentResourceName(), "queue.json"))
------------------
--- Util Functions
------------------
Strip_Control_and_Extended_Codes = function( str )
	local s = ""
	for i = 1, str:len() do
		if str:byte(i) >= 32 and str:byte(i) <= 126 then
			s = s .. str:sub(i,i)
		end
	end
	return s
 end
 ---
 Strip_Control_Codes = function( str )
	local s = ""
	for i in str:gmatch( "%C+" ) do
		 s = s .. i
	end
	return s
 end
---
getUserIdentifiers = function(source)
	local name = GetPlayerName(source)
	local firstStrip = Strip_Control_Codes(name)
	local stripName = Strip_Control_and_Extended_Codes(firstStrip)
	local ids = {}  
	ids.fivem = nil
	ids.steam  = nil
	ids.license  = nil
	ids.discord  = nil
	ids.xbl      = nil
	ids.live   = nil
	ids.ip       = nil
	ids.other = {}
	ids.lastlogin = os.time()
	ids.name = stripName
	for k,v in pairs(GetPlayerIdentifiers(source))do  
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			ids.steam = v      
		elseif string.sub(v, 1, string.len("fivem:")) == "fivem:" then
			ids.fivem = v
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			ids.license = v
		elseif string.sub(v, 1, string.len("license2:")) == "license2:" then
			ids.license2 = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			ids.xbl  = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			ids.ip = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			ids.discord = v
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			ids.live = v
		else
			table.insert(ids.other, v)
		end    
	end
	return ids
 end
---
execQuery = function(fn, query, parameters)
    local result = fn(query, parameters)
    return result
end
------------------
--- Database Calls
------------------
DBLog = function(msg)
	local firstStrip = Strip_Control_Codes(msg)
	local stripmsg = Strip_Control_and_Extended_Codes(firstStrip)
	local jsonmsg = json.encode(stripmsg)
    local stripmsgdb = execQuery(MySQL.query.await, 'INSERT INTO `_mkLog` (logmsg) VALUES (?)', {jsonmsg})
	print(stripmsg)
end
---
function CheckBanList(ids)
	local foundUser = nil
	-- check license
	local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `license` = ?', { ids.license })
	if dbUser[1] ~= nil then
        foundUser = dbUser[1]
	end
	-- check fivem
	if ids.fivem ~= nil then
		local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `fivem` = ?', { ids.fivem })
		if dbUser[1] ~= nil then
			foundUser = dbUser[1]
		end
	end
	-- check steam
	if ids.steam ~= nil then
		local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `steam` = ?', { ids.steam })
		if dbUser[1] ~= nil then
			foundUser = dbUser[1]
		end	
	end
	-- check discord
	if ids.discord ~= nil then
		local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `discord` = ?', { ids.discord })
		if dbUser[1] ~= nil then
			foundUser = dbUser[1]
		end
	end
	-- check xbl
	if ids.xbl ~= nil then
		local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `xbl` = ?', { ids.xbl })
		if dbUser[1] ~= nil then
			foundUser = dbUser[1]
		end
	end
	-- check live
	if ids.live ~= nil then
		local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `live` = ?', { ids.live })
		if dbUser[1] ~= nil then
			foundUser = dbUser[1]
		end
	end
	-- check ip
	if ids.ip ~= nil then
		local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `ip` = ?', { ids.ip })
		if dbUser[1] ~= nil then
			foundUser = dbUser[1]
		end
	end
	if foundUser ~= nil then
		return foundUser
	else
		return -1
	end	
end
---
function UpdateIdentifiers(ids)
	if ids.fivem ~= nil then
		local updateId = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `fivem` = ? WHERE `license` = ?', { ids.fivem, ids.license })
	end
	if ids.steam ~= nil then
		local updateId = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `steam` = ? WHERE `license` = ?', { ids.steam, ids.license })
	end
	if ids.discord ~= nil then
		local updateId = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `discord` = ? WHERE `license` = ?', { ids.discord, ids.license })
	end
	if ids.xbl ~= nil then
		local updateId = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `xbl` = ? WHERE `license` = ?', { ids.xbl, ids.license })
	end
	if ids.live ~= nil then
		local updateId = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `live` = ? WHERE `license` = ?', { ids.live, ids.license })
	end
	if ids.ip ~= nil then
		local updateId = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `ip` = ? WHERE `license` = ?', { ids.ip, ids.license })
	end
	print('Updated Player Secondary Identifiers:', ids.license)
end
---
function CheckAccount(ids)
	local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkAccount` WHERE `license` = ?', { ids.license })
	if dbUser[1] ~= nil then
		UpdateIdentifiers(ids)
        return dbUser[1]
    else
        local newUser = execQuery(MySQL.query.await, 'INSERT INTO `_mkAccount` (license, name, ip) VALUES (?,?,?)', { ids.license, ids.name, ids.ip })
		UpdateIdentifiers(ids)
		local newConsumables = execQuery(MySQL.query.await, 'INSERT INTO `_mkConsumables` (license) VALUES (?)', { ids.license })
    	local dbuser2 = execQuery(MySQL.query.await, 'SELECT * FROM `_mkAccount` WHERE `license` = ?', { ids.license })
		return dbuser2[1]
	end
end
---
function MakeRoomForStaff()
	if OnlineClient[1] ~= nil then
		DropPlayer(OnlineClient[1].pSrc, 'Player Removed For Staff Connection. Please Requeue. Our Apologies!')
		OnlineClient[1] = nil
	end
end
---
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local pSrc = source
	local pIds = getUserIdentifiers(pSrc)
    deferrals.defer()
	-----------------------
    Citizen.Wait(10)
	local cdown = 10
	local strText = 'Time Remaining: '..cdown..' Seconds.'
	deferrals.presentCard(TermsCard)
	while cdown > 0 do
		local strText = 'Time Remaining: '..cdown..' Seconds.'
		TermsCard.body[1].items[1].columns[2].items[5].text = strText
		deferrals.presentCard(TermsCard)
		cdown = (cdown-1)
    	Citizen.Wait(1000)
	end
	TextCard.body[1].items[1].columns[2].items[2].columns[2].items[2].text = 'License Check.'
	deferrals.presentCard(TextCard)
	Citizen.Wait(1000)    
    if pIds.license == nil then 
		DBLog('License Missing: ['..pSrc..']')
        deferrals.done('No License?? Thats an Issue, Restart FiveM')
        CancelEvent()
    end
	TextCard.body[1].items[1].columns[2].items[2].columns[2].items[3].text = 'Name Check.'
	deferrals.presentCard(TextCard)
	Citizen.Wait(1000)
    if pIds.name == nil or pIds.name == "" then 
		DBLog('Name Missing: ['..pSrc..']')
        deferrals.done('Your Name is broken!?? Thats an Issue, Restart FiveM')
        CancelEvent()
    end
	TextCard.body[1].items[1].columns[2].items[2].columns[2].items[4].text = 'Ban Check.'
	deferrals.presentCard(TextCard)
	Citizen.Wait(1000)       
    if CheckBanList(pIds) ~= -1 then
		DBLog('Banned Connection: ['..pSrc..'] '..pIds.name..'')  
        deferrals.done('One or more of your details are Banned. Contact Staff.')
        CancelEvent()
    end
	DBLog('Deferrals Completed for: ['..pSrc..'] '..pIds.name..'')     
	-- --
	local pAccount = CheckAccount(pIds)
	pAccount.pSrc = pSrc
	pAccount.deferrals = deferrals
	pAccount.qStart = os.time()
	if pAccount.permissions ~= nil then
		local perms = json.decode(pAccount.permissions)
		if perms.staff then
			table.insert(QueueStaff, 1, pAccount)
		end
		if perms.prio then
			table.insert(QueuePrio, 1, pAccount)
		end
	else
		table.insert(QueueClient, 1, pAccount)
	end
end)
----------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		-- staff queue
		for i, qPlayer in pairs(QueueStaff) do
			if #OnlineClient < maxPlayerCap then
				table.insert(OnlineClient, 1, QueueStaff[i])
				QueueStaff[i]= nil
				qPlayer.deferrals.done()
			else
				MakeRoomForStaff()
				table.insert(OnlineClient, 1, QueueStaff[i])
				QueueStaff[i]= nil
				qPlayer.deferrals.done()
			end
		end
		-- prio queue
		for i, qPlayer in pairs(QueuePrio) do
			if #OnlineClient < maxPlayerCap then
				table.insert(OnlineClient, 1, QueuePrio[i])
				QueuePrio[i]= nil 
				qPlayer.deferrals.done()				
			else
				if GetPlayerEndpoint(qPlayer.pSrc) ~= nil then
					local qDiff = (os.time() - qPlayer.qStart)
					local qpos = 'In Priority Queue [ '..#QueuePrio..' ] Position [ '..i..' ]'
					local tIQ = 'Time In Queue: ['..qDiff..']'
					QueueCard.body[1].items[1].columns[2].items[2].columns[2].items[2].text = qpos
					QueueCard.body[1].items[1].columns[2].items[2].columns[2].items[3].text = tIQ
					qPlayer.deferrals.presentCard(QueueCard)
				else
					QueuePrio[i]= nil
				end	
			end
		end
		-- player queue
		for i, qPlayer in pairs(QueueClient) do
			if #OnlineClient < maxPlayerCap then 
				table.insert(OnlineClient, 1, QueueClient[i])
				QueueClient[i]= nil 
				qPlayer.deferrals.done()				
			else
				if GetPlayerEndpoint(qPlayer.pSrc) ~= nil then
					local qDiff = (os.time() - qPlayer.qStart)
					local qpos = 'In Player Queue [ '..#QueueClient..' ] Position [ '..i..' ]'
					local tIQ = 'Time In Queue: ['..qDiff..']'
					QueueCard.body[1].items[1].columns[2].items[2].columns[2].items[2].text = qpos
					QueueCard.body[1].items[1].columns[2].items[2].columns[2].items[3].text = tIQ
					qPlayer.deferrals.presentCard(QueueCard)
				else
					QueueClient[i]= nil
				end	
			end
		end
		-- online player check
		for i, qPlayer in pairs(OnlineClient) do
			if GetPlayerEndpoint(qPlayer.pSrc) ~= nil then
				OnlineClient[i]= nil
			end
		end
		Citizen.Wait(100)
  	end
end)