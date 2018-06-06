local uGM_items = {}

function uGM_getItems( name )
	if uGM_items[name] then
		return uGM_items[name]
	end
	return false
end

uGM_items["table1"] = {
					name	= "A Normal Table",
					desc	= "The finest of ikea furnature",
					ent		= "item_basic",
					prices	= {
						buy		= 18,
						sell	= 8,
					},
					model	= "models/props_c17/FurnitureTable002a.mdl",

					use 	= 	function(ply, ent)
								end,

					spawn 	= 	function(ply, ent)
									ent:SetItemName("table")
									print("Hello!")
								end,
					skin = 0,
					buttonDist=130,
					}

uGM_items["table2"] = {
					name	= "A Mahogany Table",
					desc	= "The finest Mahogany desk",
					ent		= "item_basic",
					prices	= {
						buy		= 30,
						sell	= 20,
					},
					model	= "models/props_combine/breendesk.mdl",

					use 	= 	function(ply, ent)
									
								end,

					spawn 	= 	function(ply, ent)
									ent:SetItemName("table")
								end,
					skin = 0,
					buttonDist=175,
					}
uGM_items["can1"] = {
					name	= "A Drink of Soda",
					desc	= "The finest Drink",
					ent		= "item_basic",
					prices	= {
						buy		= 2,
						sell	= 1,
					},
					model	= "models/props_junk/PopCan01a.mdl",

					use 	= 	function(ply, ent)
									if ply:IsValid() then
										ply:SetHealth( ply:Health() + 2 )
										if ent then
											ent:Remove()
										end
									end
								end,

					spawn 	= 	function(ply, ent)
									ent:SetItemName("table")
								end,
					skin = 0,
					buttonDist=25,
				}