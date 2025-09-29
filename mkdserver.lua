math.randomseed(os.time())
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
local maxPlayerCap = -1 -- set this to YOUR city max player cap. change from maxcap to -1 to simulate full.
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////
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
	local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkBanList` WHERE `license` = ?', { ids.license })
	if dbUser[1] ~= nil then
        return dbUser
    else
        return -1
	end
end
---
function CheckAccount(ids)
	local dbUser = execQuery(MySQL.query.await, 'SELECT * FROM `_mkAccount` WHERE `license` = ?', { ids.license })
	if dbUser[1] ~= nil then
		local updateuserids = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `fivem` = ?, `steam` = ?, `discord` = ?, `xbl` = ?, `live` = ?, `ip` = ? WHERE `license` = ?', { ids.fivem, ids.steam, ids.discord, ids.xbl, ids.live, ids.ip, ids.license })
        return dbUser
    else
        local newUser = execQuery(MySQL.query.await, 'INSERT INTO `_mkAccount` (license, name, ip) VALUES (?,?,?)', { ids.license, ids.name, ids.ip })
		local updateuserids = execQuery(MySQL.query.await, 'UPDATE `_mkAccount` SET `fivem` = ?, `steam` = ?, `discord` = ?, `xbl` = ?, `live` = ?,`license2` = ?, WHERE `license` = ?', { ids.fivem, ids.steam, ids.discord, ids.xbl, ids.live, ids.license2, ids.license })
		local newConsumables = execQuery(MySQL.query.await, 'INSERT INTO `_mkConsumables` (license) VALUES (?)', { ids.license })
    	local dbuser2 = execQuery(MySQL.query.await, 'SELECT * FROM `_mkAccount` WHERE `license` = ?', { ids.license })
		return dbuser2
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
        setKickReason('No License?? Thats an Issue, Restart FiveM')
		DBLog('License Missing: ['..pSrc..']')
        CancelEvent()
    end
	TextCard.body[1].items[1].columns[2].items[2].columns[2].items[3].text = 'Name Check.'
	deferrals.presentCard(TextCard)
	Citizen.Wait(1000)
    if pIds.name == nil or pIds.name == "" then 
        setKickReason('Your Name is broken!?? Thats an Issue, Restart FiveM')
		DBLog('Name Missing: ['..pSrc..']')
        CancelEvent()
    end
	TextCard.body[1].items[1].columns[2].items[2].columns[2].items[4].text = 'Ban Check.'
	deferrals.presentCard(TextCard)
	Citizen.Wait(1000)       
    if CheckBanList(pIds) ~= -1 then
        setKickReason('One or more of your details are Banned. Contact Staff.')
		DBLog('Banned Connection: ['..pSrc..'] '..pIds.name..'')  
        CancelEvent()
    end
	TextCard.body[1].items[1].columns[2].items[2].columns[2].items[5].text = 'Deferrals Completed for: ['..pSrc..'] '..pIds.name..'. Please wait.'
	deferrals.presentCard(TextCard)
	Citizen.Wait(2500) 
	DBLog('Deferrals Completed for: ['..pSrc..'] '..pIds.name..'')     
	-- --
	local pAccount = CheckAccount(pIds)
	if pAccount[1]['permissions'] ~= nil then
		local pPerms = json.decode(pAccount[1]['permissions'])
		if pPerms.wl ~= nil then
			if pPerms.wl >= 1 then
				pAccount.deferrals = deferrals
				pAccount.qStart = os.time()
				table.insert(QueueClient, 1, pAccount)
			else
				deferrals.done('\n=||= We are currently in Dev Testing. =||=\nOnly Staff Have Access At this Time.\nTry Again Later')
			end
		else
			deferrals.done('\n=||= We are currently in Dev Testing. =||=\nOnly Staff Have Access At this Time.\nTry Again Later')
		end
	else
		deferrals.done('\n=||= We are currently in Dev Testing. =||=\nOnly Staff Have Access At this Time.\nTry Again Later')
	end
end)
----------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		for i, qPlayer in pairs(QueueClient) do
			if #OnlineClient < maxPlayerCap then 
				qPlayer.deferrals.done()				
			else
				-- check player exists using playerendpoint
				-- if not splice user out of queue				
				local qDiff = (os.time() - qPlayer.qStart)
				local qpos = 'In Queue [ '..#QueueClient..' ] Position [ '..i..' ]'
				local tIQ = 'Time In Queue: ['..qDiff..']'
				QueueCard.body[1].items[1].columns[2].items[2].columns[2].items[2].text = qpos
				QueueCard.body[1].items[1].columns[2].items[2].columns[2].items[3].text = tIQ
				qPlayer.deferrals.presentCard(QueueCard)
			end
		end
		Citizen.Wait(100)
  	end
end)