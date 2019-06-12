script.on_event(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	local inventories = {
		defines.inventory.character_main,
		defines.inventory.character_guns,
		defines.inventory.character_ammo,
		defines.inventory.character_armor,
		defines.inventory.character_vehicle,
		defines.inventory.character_trash
	}

	-- Setup kit presets
	local kits = {}

	-- Small kit
	kits["small"] = {}
	kits["small"]["items"] = {
		{"iron-plate", 192},
		{"copper-plate", 200},
		{"iron-gear-wheel", 50},
		{"transport-belt", 500},
		{"splitter", 50},
		{"underground-belt", 50},
		{"burner-mining-drill", 20},
		{"coal", 100}
	}

	-- Starter kit
	kits["starter"] = {}
	kits["starter"]["items"] = {
		{"iron-plate", 292},
		{"copper-plate", 250},
		{"iron-gear-wheel", 50},
		{"transport-belt", 800},
		{"splitter", 50},
		{"underground-belt", 50},
		{"electric-mining-drill", 30},
		{"stone-furnace", 48},
		{"inserter", 100},
		{"coal", 100},
		{"boiler", 10},
		{"steam-engine", 20},
		{"offshore-pump", 1}
	}
	kits["starter"]["technologies"] = {
		{"automation"},
		{"electronics"},
		{"toolbelt"},
		{"logistics"},
		{"electric-energy-distribution-1"}
	}

	-- Medium kit, with power armor and basic construction bots.
	kits["medium"] = {}
	kits["medium"]["items"] = {
		{"iron-plate", 592},
		{"copper-plate", 400},
		{"iron-gear-wheel", 200},
		{"electronic-circuit", 200},
		{"transport-belt", 1100},
		{"underground-belt", 50},
		{"splitter", 50},
		{"stone-furnace", 99},
		{"assembling-machine-1", 20},
		{"inserter", 300},
		{"long-handed-inserter", 50},
		{"steel-chest", 50},
		{"electric-mining-drill", 50},
		{"medium-electric-pole", 200},
		{"boiler", 10},
		{"steam-engine", 20},
		{"offshore-pump", 1},
		{"pipe-to-ground", 50},
		{"pipe", 50},
		{"car", 1},
		{"coal", 200},
		{"construction-robot", 50},
		{"lab", 10},
		{"deconstruction-planner", 1}
	}
	kits["medium"]["armorName"] = "power-armor"
	kits["medium"]["armorItems"] = {
		{"fusion-reactor-equipment"},
		{"personal-roboport-equipment"},
		{"personal-roboport-equipment"},
		{"personal-roboport-equipment"},
		{"personal-roboport-equipment"},
		{"personal-roboport-equipment"},
		{"battery-equipment"},
		{"battery-equipment"},
		{"battery-equipment"}
	}

	kits["medium"]["technologies"] = {
		{"automation"},
		{"electronics"},
		{"toolbelt"},
		{"logistics"},
		{"electric-energy-distribution-1"},
		{"steel-axe"}
	}


	-- Big kit, with power-armor-mk2 and a lot of extra stuff.
	kits["big"] = {}
	kits["big"]["items"] = {
		{"iron-plate", 592},
		{"copper-plate", 400},
		{"iron-gear-wheel", 200},
		{"electronic-circuit", 200},
		{"advanced-circuit", 200},
		{"transport-belt", 1500},
		{"underground-belt", 50},
		{"splitter", 50},
		{"steel-furnace", 100},
		{"assembling-machine-2", 100},
		{"inserter", 300},
		{"long-handed-inserter", 50},
		{"steel-chest", 50},
		{"electric-mining-drill", 50},
		{"medium-electric-pole", 350},
		{"big-electric-pole", 100},
		{"logistic-chest-requester", 100},
		{"logistic-chest-passive-provider", 100},
		{"boiler", 20},
		{"steam-engine", 40},
		{"offshore-pump", 10},
		{"pipe-to-ground", 100},
		{"pipe", 100},
		{"chemical-plant", 20},
		{"oil-refinery", 10}, 
		{"car", 1},
		{"coal", 50},
		{"roboport", 20},
		{"construction-robot", 50},
		{"logistic-robot", 300},
		{"lab", 10},
		{"deconstruction-planner", 1},
		{"storage-tank", 10},
		{"logistic-chest-storage", 50}
	}

	kits["big"]["armorName"] = "power-armor-mk2"
	kits["big"]["armorItems"] = {
		{"fusion-reactor-equipment"},
		{"fusion-reactor-equipment"},
		{"fusion-reactor-equipment"},
		{"exoskeleton-equipment"},
		{"exoskeleton-equipment"},
		{"exoskeleton-equipment"},
		{"exoskeleton-equipment"},
		{"energy-shield-mk2-equipment"},
		{"energy-shield-mk2-equipment"},
		{"personal-roboport-mk2-equipment"},
		{"night-vision-equipment"},
		{"battery-mk2-equipment"},
		{"battery-mk2-equipment"}
	}

	kits["big"]["technologies"] = {
		{"automation"},
		{"steel-processing"},
		{"automation-2"},
		{"oil-processing"},
		{"plastics"},
		{"advanced-electronics"},
		{"sulfur-processing"},
		{"battery"},
		{"toolbelt"},
		{"electronics"},
		{"engine"},
		{"electric-engine"},
		{"flying"},
		{"robotics"},
		{"logistic-robotics"},
		{"construction-robotics"},
		{"logistic-system"},
		{"fluid-handling"},
		{"steel-axe"}
	}

	local kitSetting = settings.startup["a-better-start"].value
	local techSetting = settings.startup["a-better-start-technologies"].value
	local beltImmunitySetting = settings.startup["a-better-start-belt-immunity"].value
	local kit = kits[kitSetting]
	if kit == nil then
		kit = kits["medium"]
	end

	-- Inject armor name if it is defined for this kit.
	if kit["armorName"] ~= nil then
		table.insert(kit["items"], {kit["armorName"], 1})
	end

	-- Inject belt immunity equipment and technology if requested
	if beltImmunitySetting then
		table.insert(kit["armorItems"], {"belt-immunity-equipment"})
		if techSetting then
			table.insert(kit["technologies"], {"belt-immunity-equipment"})
		end
	end

	-- Add items
	for k,v in pairs(kit["items"]) do
		if v[1] ~= nil then
			player.insert{name = v[1], count = v[2]}
		end
	end

	if kit["armorName"] ~= nil then
		-- Find armor in one of the inventories
		-- Usually ends up in the armor slot. But that one does not exist in sandbox mode
		local armorName = kit["armorName"]
		found = false
		for k,v in pairs(inventories) do
			local inventory = player.get_inventory(v)
			if inventory ~= nil then
				local armor = inventory.find_item_stack(armorName)
				if armor ~= nil then
					-- Add items to armor grid
					local grid = armor.grid
					for k,v in pairs(kit["armorItems"]) do
						grid.put{name = v[1]}
					end
					found = true;
					break
				end
			end
		end

		if found == false then
			player.print("Warning: unable to find armor " .. armorName .. " in inventory")
		end
	end

	-- Unlock 
	if techSetting then
		if kit["technologies"] ~= nil then
			for k,v in pairs(kit["technologies"]) do
				if player.force.technologies[v[1]] ~= nil then
					player.force.technologies[v[1]].researched = true
				end
			end
		end
	end
end)
