AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel( uGM_getItems( self:GetNWString("uGM_itemName") ).model )

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then phys:EnableGravity(true) phys:Wake() end

	uGM_getItems( self:GetNWString("uGM_itemName") ).spawn( self:GetNWEntity("uGM_owner") , self) 
end

function ENT:SetItemName( name )
	self.uGM_itemName = name
end

function ENT:Use(activator, caller)
	uGM_getItems( self:GetNWString("uGM_itemName") ).use(activator, self)
end

function ENT:Touch( ent )
end

function ENT:OnRemove()
end

function ENT:Think()
end