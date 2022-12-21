
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/ut2004/weaponstaticmesh/redeemermissile.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	--util.SpriteTrail( self, 0, Color( 255,190,50 ), false, 64, 32, .1, 1 / 54, "particles/fire_glow.vmt" )
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(5)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end

	self.flysound = CreateSound(self, "ut2004/weaponsounds/misc/redeemer_flight.wav")
	self.flysound:Play()

	--self.Owner = self:GetVar("owner",Entity(1))
	if SERVER then self:SetLagCompensated(true) end
end

function ENT:PhysicsCollide(data)
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	--util.Decal("ut99bigblast",start,endpos)

	self:Explode()
end

function ENT:PhysicsUpdate(phys)
	if self:WaterLevel() >= 1 then
		phys:SetVelocity(self:GetForward() *600)
	end
end

function ENT:Explode()
	ParticleEffect( "ut2004_redeemer_exp", self:GetPos(), self:GetAngles() )
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetScale(512)
	timer.Simple(0.75, function() 
		util.Effect("ut2004_redeemer_exp", effectdata, true, true)
	end)
	self:EmitSound("ut2004/weaponsounds/misc/redeemer_explosionsound.wav", 500)
	self:Remove()
	
	local owner = self:GetOwner()
	
	util.ScreenShake( self:GetPos(), 50, 255, 2, 2048 )
	local explosion = ents.Create( "ut2004_redeemer_exp" )
	explosion:SetOwner( owner )
	explosion:SetPos( self:GetPos() )
	explosion:Spawn()
	explosion:Activate()
end

function ENT:ExplodeHarmless()
	ParticleEffect( "ut2004_redeemer_exp", self:GetPos(), self:GetAngles() )
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetScale(512)
	timer.Simple(0.75, function() 
		util.Effect("ut2004_redeemer_exp", effectdata, true, true)
	end)
	self:EmitSound("ut2004/weaponsounds/misc/redeemer_explosionsound.wav", 500, 100)
	self:Remove()
	
	util.ScreenShake( self:GetPos(), 50, 255, 2, 2048 )
end

function ENT:OnRemove()
	if self.flysound then self.flysound:Stop() end
end