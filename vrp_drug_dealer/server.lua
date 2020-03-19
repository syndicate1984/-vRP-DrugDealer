local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_drugs")

print("[PLES/Syndicate] Las aici creditele ca nu s scartar!Ples e vaita")

local tdCords = {2506.0776367188,4800.7451171875,34.996700286865}
local lots = {0}

local menu_confisca = {
	name = "Drugs",
	css={top = "75px", header_color="rgba(226, 87, 36, 0.75)"}
}

menu_confisca["Incepe sa plantezi"] = {function(player, choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		if vRP.hasPermission({user_id, "harvest.weed"}) then
			vRPclient.notify(player, {"~g~Incepi sa plantezi niste iarba~n~~w~Du-te pe camp si pune semintele in pamant"})
			TriggerClientEvent("ples:startPlant", player)
		else
			vRPclient.notify(player, {"~r~Nu stii sa te ocupi cu asa ceva, du-te la delivery"})
		end
	end
	vRP.closeMenu({player})
end, "Va trebuii sa mergi pe camp si sa pui semintele in pamant"}

local function updateWeed(player, k, v)
	TriggerClientEvent("ples:updateLots", player, k, v)
	TriggerClientEvent("ples:updateStates", -1, k, v)
	if v ~= 2 then
		TriggerClientEvent("ples:setLotName", -1, k, GetPlayerName(player))
	else
		TriggerClientEvent("ples:setLotName", -1, k, nil)
	end
end

local lotOwners = {0}

RegisterServerEvent("ples:planteazaTata")
AddEventHandler("ples:planteazaTata", function(lotID)
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	if lots[lotID] ~= 2 then
			if vRP.hasPermission({user_id, "harvest.weed"}) then
		if vRP.tryGetInventoryItem({user_id, "water", 1, false}) then

			lotOwners[lotID] = user_id
			vRPclient.playAnim(player, {false, {task="WORLD_HUMAN_GARDENER_PLANT"}, false})
			SetTimeout(10000, function()
				vRPclient.stopAnim(player, {false})
				SetTimeout(5000, function()
					-- apare planta mica
					lots[lotID] = 1
					updateWeed(player, lotID, lots[lotID])

					-- creste weed-ul
					SetTimeout(40000, function()
						lots[lotID] = 2
						updateWeed(player, lotID, lots[lotID])

						SetTimeout(120000, function()
							if lots[lotID] == 2 then
								lotOwners[lotID] = 0
								lots[lotID] = 0
								updateWeed(player, lotID, lots[lotID])
							end
						end)
					end)
				end)
			end)
		else
			vRPclient.notify(player, {"~r~Nu ai seminte pe care sa le plantezi"})
		end
	else
		vRPclient.notify(player, {"~r~Nu ai permisie de la Nea Gicu sa plantezi aici!"})
	end
	elseif lots[lotID] == 2 then

		if lotOwners[lotID] == user_id then
			vRPclient.playAnim(player, {false, {task="PROP_HUMAN_PARKING_METER"}, false})
			SetTimeout(6000, function()
				vRPclient.stopAnim(player, {false})
				lots[lotID] = 0
                local new_weight = vRP.getInventoryWeight({user_id})+vRP.getItemWeight({"water"})
			if new_weight <= vRP.getInventoryMaxWeight({user_id}) then
				vRP.giveInventoryItem({user_id, "water", math.random(1, 3), true})
				updateWeed(player, lotID, lots[lotID])
			else
				vRPclient.notify(player, {"~r~Inventar plin!"})
			end
			end)
		else
			vRPclient.notify(player, {"~r~Aceasta planta nu iti apartine"})
		end

	end
end)

local function build_confisca(source)
	local user_id = vRP.getUserId({source})
	if user_id ~= nil then
		TriggerClientEvent("ples:syncOwners", source, lotOwners)

		local x, y, z = table.unpack(tdCords)

		local conf_enter = function(player, area)
			local user_id = vRP.getUserId({player})
			if user_id ~= nil then
				if menu_confisca then vRP.openMenu({player, menu_confisca}) end

			end
		end

		local conf_leave = function(player, area)
			vRP.closeMenu({player})
		end

		vRPclient.addBlip(source, {x, y, z, 496, 69, "Camp De Canabis"})
		vRPclient.addMarker(source,{x,y,z-0.95,1,1,0.9,0, 66, 134, 244,150})
		vRP.setArea({source, "vRP:confisatdePles", x, y, z, 3, 2, conf_enter, conf_leave})
	end
end

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
  if first_spawn then
    build_confisca(source)
  end
end)


RegisterCommand("buildconfisca", function(ply)
    build_confisca(ply)
end)
