AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/ut2004/weapons/ioncannon.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		--phys:Wake()
		phys:EnableGravity(false)
	end
end


function ENT:PhysicsCollide(data, phys)
	
end

function ENT:OnRemove()
	
end

function ENT:Think()
	
end