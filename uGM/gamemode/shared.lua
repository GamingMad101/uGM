GM.Name = "uGM"
GM.Author = "GamingMad101"
GM.Email = "N/A"
GM.Website = "N/A"

DEV_MODE = GetConVar("ugm_devmode"):GetBool() or false

if DEV_MODE then DeriveGamemode( "sandbox" ) print( "uGM Initialized in Dev Mode, If this is unintentional, check your settings.") else DeriveGamemode( "base" ) print( "uGM Initialized in Standalone Mode") end

