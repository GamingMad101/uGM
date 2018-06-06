local ply = FindMetaTable("Player")

util.AddNetworkString("uGM_databasenet")
util.AddNetworkString("uGM_inventory_drop")
util.AddNetworkString("uGM_inventory_use")


function ply:uGM_ID()
	local id = self:SteamID64()
	return id
end

function ply:uGM_databaseDefault()
	self.uGM_database = {}
	self:uGM_databaseSetValue( "money", GetConVar("ugm_startcash"):GetInt() or 1000 )
	local i = {}
	i["table1"] 	= 	{ amount = 10 }
	i["table2"]	= 	{ amount = 10 }
	self:uGM_databaseSetValue("inventory", i )
end

function ply:uGM_databaseNetworkedData()
	local money = self:uGM_databaseGetValue("money")
	self:SetNWInt("money", money)
end

function ply:uGM_databaseFolders()
	return "uGM/players/" .. self:uGM_ID() .. "/"
end

function ply:uGM_databasePath()
	return self:uGM_databaseFolders() .. "database.txt"
end

function ply:uGM_databaseSet( tab )
	self.uGM_database = tab
end

function ply:uGM_databaseGet()
	return self.uGM_database
end

function ply:uGM_databaseCheck()
	self.uGM_database = {}
	local f = self:uGM_databaseExists()
	if f then
		self:uGM_databaseRead()
	else
		self:uGM_databaseCreate()
	end
	self:uGM_databaseSend()
	self:uGM_databaseNetworkedData()
end

function ply:uGM_databaseSend()
	net.Start("ugm_databaseNet")
		net.WriteTable( self:uGM_databaseGet() or {} )
	net.Send( self )
end

function ply:uGM_databaseExists()
		return file.Exists( self:uGM_databasePath() , "DATA")
end

function ply:uGM_databaseRead()
	local str = file.Read(self:uGM_databasePath() , "DATA" )
	self:uGM_databaseSet( util.JSONToTable(str)  )	
end

function ply:uGM_databaseSave()
	local str = util.TableToJSON( self.uGM_database , true )
	local f = file.Write( self:uGM_databasePath(), str )
	self:uGM_databaseSend()
end

function ply:uGM_databaseCreate()
	self:uGM_databaseDefault()
	file.CreateDir( self:uGM_databaseFolders() )
	self:uGM_databaseSave()
end

function ply:uGM_databaseDisconnect()
	self:uGM_databaseSave()
end

function ply:uGM_databaseSetValue( name, v )
	if (type(v) == "table") then
		if name == "inventory" then
			for k,b in pairs(v) do
				if b.amount <= 0 then
					v[k] = nil
				end


			end
		end
	end


	local d = self:uGM_databaseGet() or {}
	d[name] = v

	self:uGM_databaseSave()
end

function ply:uGM_databaseGetValue(name)
	local d = self:uGM_databaseGet() or {}
	return d[name]
end

function ply:uGM_inventorySave( i )
	if not i then return end
	
	self:uGM_databaseSetValue( "inventory" , i )

end

function ply:uGM_inventoryGet()
	local i = self:uGM_databaseGetValue( "inventory" )
	return i
end

function ply:uGM_inventoryHasItem(name , amount)
	if not amount then amount = 1 end
	
	local i = self:uGM_inventoryGet()

	if i then
		if i[name] then
			if i[name].amount >= amount then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false	
	end
end

function ply:uGM_inventoryTakeItem(name, amount)
	if not amount then amount = 1 end
	
	local i = self:uGM_inventoryGet()

	if self:uGM_inventoryHasItem(name, amount) then
		
		i[name].amount = i[name].amount - amount


		self:uGM_inventorySave(i)

		return true
	else
		return false
	end
end	

function ply:uGM_inventoryGiveItem(name, amount)
	if not amount then amount = 1 end
	
	local i = self:uGM_inventoryGet()

	local item = uGM_getItems( name )

	if not item then return end

	if amount == 1 then
		self:PrintMessage( HUD_PRINTTALK, "You've have recieved a " .. item.name )

	elseif amount > 1 then
		self:PrintMessage( HUD_PRINTTALK, "You've have recieved " .. amount .. " " .. item.name .. "'s")
	end

	if self:uGM_inventoryHasItem(name, 1) then
		i[name].amount = i[name].amount + amount
	else
		i[name] = { amount = amount }
	end
	
	self:uGM_inventorySave( i )
end

net.Receive("uGM_inventory_drop", function(len,ply)

	local name = net.ReadString()

	if ply:uGM_inventoryHasItem(name, 1 ) then
		ply:uGM_inventoryTakeItem( name, 1)
		uGM_CreateItem( ply, name, uGM_itemSpawnPos(ply) )
	end


end)


net.Receive("uGM_inventory_use", function(len,ply)

	local name = net.ReadString()

	local item = uGM_getItems( name )

	if item then
		if ply:uGM_inventoryHasItem(name, 1) then
			ply:uGM_inventoryTakeItem( name, 1)
			item.use( ply )
		end
	end

end)

local idd = 0

function uGM_CreateItem( ply, name, pos )
	local itemT = uGM_getItems( name )
	if itemT then
		idd = idd + 1
		local item = ents.Create( itemT.ent )
		item:SetNWString( "uGM_name" , itemT.name )
		item:SetNWString( "uGM_itemName" , name )
		item:SetNWInt( "uGM_uID" , idd )
		item:SetNWBool( "uGM_pickup", true )
		item:SetPos( pos )
		item:SetNWEntity( "uGM_owner", ply )
		item:SetSkin( itemT.skin or 0 )
		itemT.spawn(ply, item)

		item:Spawn()
		item:Activate()
	else
		return false
	end
end

function uGM_itemSpawnPos( ply )
	local pos = ply:GetShootPos()
	local ang = ply:GetAimVector()

	local td = {}
	td.start = pos
	td.endpos = pos+ang*80
	td.filter = ply
	local trace = util.TraceLine(td)
	return trace.HitPos
end

function uGM_inventoryPickup( ply )
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = player.GetAll()
	local tr = util.TraceLine(trace)

	if tr.HitWorld then return end
	if !tr.Entity:IsValid() then return end
	
	if tr.Entity:GetNWBool("uGM_pickup") then
		local item = uGM_getItems( tr.Entity:GetNWString("uGM_itemName") )
		if item.canPickup == nil then
			ply:uGM_inventoryGiveItem( tr.Entity:GetNWString("uGM_itemName"), 1 )
			tr.Entity:Remove()
		else
			if tr.Entity:GetNWBool("uGM_pickup") then
				ply:uGM_inventoryGiveItem( tr.Entity:GetNWString("uGM_itemName"), 1 )
				tr.Entity:Remove()
			end
		end
	end
end
hook.Add( "ShowSpare1", "uGM_inventoryPickup", uGM_inventoryPickup )