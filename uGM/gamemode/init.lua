AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "database/cl_database.lua")
AddCSLuaFile( "database/items.lua")

include( "shared.lua" )
include( "database/database.lua" )
include( "database/items.lua" )

function GM:PlayerAuthed( ply, steamID, UniqueID )
	ply:uGM_databaseCheck()
end

function GM:PlayerDisconnected( ply )
	ply:uGM_databaseDisconnect()
end

function GM:ShowSpare2( ply )
	ply:ConCommand( "uGM_inventory" )
end

function GM:ShowHelp( ply )
	ply:uGM_databaseCreate()
	ply:ConCommand("say 'I have just reset my inventory!' ")
end