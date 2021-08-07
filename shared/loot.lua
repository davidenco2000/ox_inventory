if ox.server then
	-- Enable random loot in dumpsters, gloveboxes, trunks
	Config.RandomLoot = true

	if Config.RandomLoot then
		local lootChance = { trunk = 100, glovebox = 100, dumpster = 100 }

		local trash = {
			{description = 'An old rolled up newspaper', weight = 200, image = 'trash_newspaper'}, 
			{description = 'A discarded burger shot carton', weight = 50, image = 'trash_burgershot'},
			{description = 'An empty soda can', weight = 20, image = 'trash_can'},
			{description = 'A mouldy piece of bread', weight = 70, image = 'trash_bread'},
			{description = 'An empty ciggarette carton', weight = 10, image = 'trash_fags'},
			{description = 'A slightly used pair of panties', weight = 20, image = 'panties'},
			{description = 'An empty coffee cup', weight = 20, image = 'trash_coffee'},
			{description = 'A crumpled up piece of paper', weight = 5, image = 'trash_paper'},
			{description = 'An empty chips bag', weight = 5, image = 'trash_chips'},
		}

		local loot = {
			['water'] = {trunk = 6, glovebox = 8, dumpster = 4, min= 1, max = 2},
			['cola'] = {trunk = 5, glovebox = 7, min = 1, max = 2},
			['bandage'] = {trunk = 6, glovebox = 8, dumpster = 2, min = 1, max = 3},
			['lockpick'] = {trunk = 2, glovebox = 3, dumpster = 2, min = 1, max = 2},
			['phone'] = {trunk = 1, glovebox = 3, min = 1, max = 1},
			['garbage'] = {trunk = 3, glovebox = 2, dumpster = 80, min = 1, max = 6}
		}

		GenerateTrash = function(metadata)
			local metadata = metadata
			local trashType = math.random(1,#trash)
			metadata.description = trash[trashType].description
			metadata.image = trash[trashType].image
			metadata.weight = trash[trashType].weight
			return metadata
		end
		exports('GenerateTrash', GenerateTrash)

		GenerateDatastore = function(type)
			local returnData = {}
			if type == 'trunk' or type == 'glovebox' or type == 'dumpster' then
				local chance = lootChance[type]
				if chance and math.random(1,100) <= chance then 
					for k,v in pairs(loot) do
						local item = Items[k]
						chance = loot[k][type]
						if chance then 
							if math.random(1,100) <= chance then 
								local lootMin, lootMax = loot[k].min, loot[k].max
								local count = math.random(lootMin,lootMax)
								if k ~= 'garbage' and item.stack then
									local slot = #returnData + 1
									local metadata, weight = {}
									if item.ammoname then
										local ammo = {}
										ammo.type = item.ammoname
										ammo.count = metadata.ammo
										ammo.weight = Items[ammo.type].weight
										weight = item.weight + (ammo.weight * ammo.count)
									else weight = item.weight end
									if metadata.weight then weight = weight + metadata.weight end
									returnData[slot] = {name = item.name , label = Items[item.name].label, weight = weight, slot = slot, count = count, description = Items[item.name].description, metadata = item.metadata, stack = Items[item.name].stack}
								else
									for i=1, count, 1 do 
										local slot = #returnData + 1
										local metadata, weight = {}
										if item.name == 'garbage' then metadata = GenerateTrash(metadata) end
										if item.ammoname then
											local ammo = {}
											ammo.type = item.ammoname
											ammo.count = metadata.ammo
											ammo.weight = Items[ammo.type].weight
											weight = item.weight + (ammo.weight * ammo.count)
										else weight = item.weight end
										if metadata.weight then weight = weight + metadata.weight end
										returnData[slot] = {name = item.name , label = Items[item.name].label, weight = weight, slot = slot, count = 1, description = Items[item.name].description, metadata = metadata, stack = Items[item.name].stack}
									end 
								end
							end
						end
					end 
				end
			end
			return returnData
		end
	end
else
	Config.Dumpsters = {218085040, 666561306, -58485588, -206690185, 1511880420, 682791951}
	
	if Config.qtarget then
		exports['qtarget']:AddTargetModel(Config.Dumpsters, {
			options = {
				{
					event = "linden_inventory:openDumpster",
					icon = "fas fa-dumpster",
					label = "Search Dumpster",
				},
			},
			distance = 2
		})
		
		AddEventHandler('linden_inventory:openDumpster', function(data)
			if func.checktable(Config.Dumpsters, GetEntityModel(data.entity)) then
				if not IsEntityAMissionEntity(data.entity) then 
					SetEntityAsMissionEntity(data.entity) 
					NetworkRegisterEntityAsNetworked(data.entity) 
					local netId = NetworkGetNetworkIdFromEntity(data.entity) 
					SetNetworkIdExistsOnAllMachines(netId, true) 
					SetNetworkIdCanMigrate(netId, true) 
					NetworkSetNetworkIdDynamic(false) 
				end 
				OpenDumpster({ id = NetworkGetNetworkIdFromEntity(data.entity), label = 'Dumpster', slots = 15}) 
			end
		end)
	end
end
