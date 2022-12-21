
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/ut2004/vmweaponssm/playerweaponsgroup/bomberbomb.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	
	self.flysound = CreateSound(self, "ut2004/weaponsounds/misc/redeemer_flight.wav")
	self.flysound:Play()

	--self:SetRemoveDelay(7)
	self.HasExploded = false
end


function ENT:PhysicsCollide(data, phys)
	if self.HasExploded then return end
	self.HasExploded = true
	/*
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("Scorch",start,endpos)
	*/
	ParticleEffect( "ut2004_bomber_explosion", self:GetPos(), self:GetAngles() )
	
	util.ScreenShake( self:GetPos(), 25, 127, 2, 1024 )
	util.BlastDamage(self, self:GetOwner(), self:GetPos(), 403, 600) --radius is 660 in original
	self:EmitSound("ut2004/weaponsounds/misc/redeemer_explosionsound.wav", 500)
	self:Remove()
end

function ENT:OnRemove()
	if self.flysound then self.flysound:Stop() end
end

function ENT:Think()
	
end