include("items.lua")
local database = database or {}

local SKINS = {}

SKINS.COLORS = {
	lightGrey = Color(131,131,131,180),
	grey = Color(111,111,111,180),
	lowWhite = Color(243,243,243,180),
	goodBlack = Color(41,41,41,230),
	transparentGrey = Color(111,111,111,30)
}

local function databaseRecieve( tab )
	database = tab
end

net.Receive( "uGM_databasenet" , function ( len )
	local tab = net.ReadTable() or {}
	databaseRecieve( tab )
end)

function uGM_databaseTable()
	return database
end

function uGM_databaseGetValue( name )
	local d = uGM_databaseTable()
	return d[name]
end

function uGM_inventoryTable()
	return uGM_databaseGetValue("inventory") or {}
end

function uGM_inventoryHasItem( name, amount )
	if not amount then amount = 1 end
	
	local i = inventoryTable()

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


function SKINS:DrawFrame(w,h)
	local topHeight = 24
	local rounded = 4
	draw.RoundedBoxEx( rounded , 0 , 0 , w , h , SKINS.COLORS.lightGrey , true, true, false, false)
	draw.RoundedBoxEx( rounded , 0 , topHeight , w , h-topHeight , SKINS.COLORS.lightGrey , false, false, true, true )
	draw.RoundedBoxEx( rounded , 2 , topHeight , w-4 , h-topHeight-2 , SKINS.COLORS.goodBlack ,  false, false, true, true )
	
	local QuadTable = {}
	QuadTable.texture = surface.GetTextureID("gui/gradient")
	QuadTable.color = Color (10,10,10,120)
	QuadTable.x = 2
	QuadTable.y = topHeight
	QuadTable.w = w-4
	QuadTable.h = h-topHeight-2
	draw.TexturedQuad( QuadTable )
end

local function inventoryItemButton( iname, name, amount, desc, model, parent, dist, buttons )
	if not dist then dist = 120 end
	local p = vgui.Create("DPanel", parent )
	p:SetPos( 4, 4 )
	p:SetSize( 64,64 )

	local mp = vgui.Create( "DModelPanel", p)
	mp:SetSize(p:GetWide(),p:GetTall())
	mp:SetPos(0,0)
	mp:SetModel( model )
	mp:SetAnimSpeed( 0.1 )
	mp:SetAnimated( true )
	mp:SetAmbientLight( Color(50,50,50 ) )
	mp:SetDirectionalLight( BOX_TOP , Color(255,255,255) )
	mp:SetCamPos( Vector(dist, dist, dist) )
	mp:SetLookAt( Vector(0,0,0) )
	mp:SetFOV( 20 )

	function mp:LayoutEntity( Entity )
		self:RunAnimation()
		Entity:SetSkin(uGM_getItems(iname).skin or 0)
		Entity:SetAngles( Angle(0,0,0) )
	end
	
	local b = vgui.Create( "DButton" , p )
	b:SetPos( 0 , 0 )
	b:SetSize(64,64)
	b:SetText("")
	b:SetTooltip( name .. ": \n\n".. desc)

	b.DoClick = function ()
		local opt = DermaMenu()
		for k,v in pairs(buttons) do 
			opt:AddOption(k,v)
		end
		opt:Open()
	end 

	b.DoRightClick = function()
	end
	
	b.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, SKINS.COLORS.transparentGrey )
	end
	
	if amount >= 0 then


		local lb = vgui.Create("DPanel", p) -- Label background
		lb:SetPos(6,4)
		lb.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, SKINS.COLORS.lowWhite )
		end

		local l = vgui.Create("DLabel", p ) -- label
		l:SetPos(6,4)
		l:SetFont("default")
		l:SetTextColor( Color(0,0,0) )
		l:SetText(amount)
		l:SizeToContents()

		lb:SetSize( l:GetSize() )

	end
	
	return p
end


local function inventoryDrop(item)
	net.Start("uGM_inventory_drop")
		net.WriteString(tostring(item))
	net.SendToServer()
end

local function inventoryUse(item)
	net.Start("uGM_inventory_use")
		net.WriteString(tostring(item))
	net.SendToServer()
end

function inventoryMenu()
	local w = 506
	local h = 512

	local f = vgui.Create("DFrame")
	f:SetSize( w , h )
	f:Center()
	f:SetTitle("Inventory")
	f:SetDraggable(true)
	f:ShowCloseButton(true)
	f:MakePopup()
	f.paint = function()
		SKINS:Drawframe(f:GetWide(), f:GetTall())
	end
	
	local ps = vgui.Create("DPropertySheet", f)
	ps:SetPos(8,28)
	ps:SetSize(w-16, h-36)

	local sc = vgui.Create("DScrollPanel", ps )
	sc:SetPos(4,4)
	sc:SetSize( ps:GetWide()-8, ps:GetTall()-8 )


	ps:AddSheet( "Items" , sc , "icon16/box.png" , false, false, "Your items are stored here" )


	local padding = 4

	local items = vgui.Create( "DIconLayout", sc )
	items:Dock(FILL)
	items:SetSpaceX(padding)
	items:SetSpaceY(padding)

	local inventory = uGM_inventoryTable()
	print( util.TableToJSON( inventory , true ) )

	local function ItemButtons()
		for k,v in pairs(inventory) do
			local i = uGM_getItems( k )
			if i then
				local buttons = {}

				buttons["use"] = (function()
					inventoryUse(k)
					print("Item Used")
					f:Close()
				end)

				buttons["drop"] = (function()
					inventoryDrop(k)
					print("Item Dropped")
					f:Close()
				end)

				local b = inventoryItemButton( k, i.name .. "(" .. v.amount .. ")", v.amount, i.desc, i.model, items, i.buttonDist, buttons )
				items:Add(b)
			end
			
		end
	end
	

	ItemButtons()



end
concommand.Add("uGM_inventory", inventoryMenu)