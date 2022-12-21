
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetModel("models/ut2004/WeaponStaticMesh/RocketProj.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	
	local glow = ents.Create( "env_sprite" )
	glow:SetKeyValue( "rendercolor","255 160 80" )
	glow:SetKeyValue( "GlowProxySize","2.0" )
	glow:SetKeyValue( "HDRColorScale","2.0" )
	glow:SetKeyValue( "renderfx","14" )
	glow:SetKeyValue( "rendermode","3" )
	glow:SetKeyValue( "renderamt","255" )
	glow:SetKeyValue( "disablereceiveshadows","0" )
	--glow:SetKeyValue( "model","sprites/blueflare1.spr" )
	glow:SetKeyValue( "model","ut2004/xeffects/RocketFlare.vmt" )
	glow:SetKeyValue( "scale",".3" )
	glow:Spawn()
	glow:SetParent( self )
	glow:SetPos( self:GetPos()+self:GetForward()*-8 )
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	
	self.flysound = CreateSound(self, "ut2004/weaponsounds/rocketlauncher/RocketLauncherProjectile.wav")
	self.flysound:Play()

	self:SetRemoveDelay(10)
	self.HasExploded = false
end

function ENT:SetRemoveDelay(flDelay)
	self.delayRemove = CurTime() +flDelay
end

function ENT:PhysicsUpdate(phys)
	if self:WaterLevel() > 2 then
		if IsValid(phys) then phys:SetVelocity(self:GetAngles():Forward() *500) return end
	end
end

function ENT:PhysicsCollide(data)
	if self.HasExploded then return end
	self.HasExploded = true
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("Scorch",start,endpos)

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	util.Effect("ut2004_exp", effectdata)
	util.Effect("ut99_explight", effectdata)
	ParticleEffect( "ut2004_flak_explosion1", self:GetPos(), self:GetAngles() )

	util.BlastDamage(self, self:GetOwner(), start, 150, 112)
	self:EmitSound("ut2004/weaponsounds/baseimpactandexplosions/BExplosion3.wav", 100, 100)
	self:Remove()
end

function ENT:OnRemove()
	if self.flysound then self.flysound:Stop() end
end

function ENT:SetTarget(ent)
	self.Target = ent
end

function ENT:Think()
	if self.Target and IsValid(self.Target) then
		self:SetAngles(self.Target:WorldSpaceCenter() - self:GetPos():Angle())
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self:GetForward() * 1200)
		end
	end

	if !self.delayRemove || CurTime() < self.delayRemove then return end
	self.delayRemove = nil
	self:Remove()
end