AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/ut2004/weaponstaticmesh/linkprojectile.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInitSphere(8, "default")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	
	--self.plsSound = CreateSound(self, "weapons/ut99/PulseFly.wav")
	--self.plsSound:Play()
	self:SetRemoveDelay(2.5)
end

function ENT:SetRemoveDelay(flDelay)
	self.delayRemove = CurTime() +flDelay
end

function ENT:PhysicsUpdate(phys)
	if self:WaterLevel() > 2 then
		if IsValid(phys) then phys:SetVelocity(self:GetForward() *700) return end
	end
end

function ENT:PhysicsCollide(data, physobj)
	data.HitEntity:TakeDamage(30 * (self.Links + 1), self:GetOwner())

	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("fadingscorch",start,endpos)

	local hitpos = endpos-self:GetForward()*4
	local effectdata = EffectData()
	effectdata:SetOrigin(hitpos)
	--util.Effect("ut99_pulsegun_hit", effectdata)
	ParticleEffect( "ut2004_link_hit", data.HitPos, data.HitNormal:Angle() )
	
	--self:EmitSound("weapons/ut99/PulseExp.wav")
	self:Remove()
end

function ENT:OnRemove()
	--if self.plsSound then self.plsSound:Stop() end
end

function ENT:Think()
	--local phys = self:GetPhysicsObject()
	--local ang = self:GetAngles()
	--if IsValid(phys) then phys:SetVelocity(ang:Forward() *2000 +ang:Right() *-5) end
	
	if !self.delayRemove || CurTime() < self.delayRemove then return end
	self.delayRemove = nil
	self:Remove()
end