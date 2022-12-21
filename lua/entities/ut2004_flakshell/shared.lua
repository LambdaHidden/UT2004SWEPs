if SERVER then
	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "cl_init.lua" )
end

ENT.Type			= "anim"
ENT.PrintName		= "UT2004 Flak Shell"
ENT.Author			= "Upset"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if SERVER then

function ENT:Initialize()
	self:SetModel("models/ut2004/weaponstaticmesh/flakshell.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetBuoyancyRatio(0)
	end
	
	self.flysound = CreateSound(self, "ut2004/weaponsounds/baseprojectilesounds/BFlakCannonProjectile.wav")
	self.flysound:Play()
	
	self.deployDelay = true
	self.HasExploded = false
end

function ENT:PhysicsCollide(data,phys)
	if data.Speed > 50 then
		self:Explode()
	end	
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter(impulse)
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal
	util.Decal("Scorch",start,endpos)
end

function ENT:Think()
	if self.deployDelay then
		self.deployDelay = nil
	end
end

function ENT:OnRemove()
	if self.flysound then self.flysound:Stop() end
end

function ENT:DoChunk(force)
	local ent = ents.Create("ut2004_flakchunk")
	local pos = self:GetPos()
	local ang = pos:Angle()
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetVar("owner",self.Owner)
	ent:SetOwner(self.Owner)
	ent:SetRemoveDelay(3)
	ent:Spawn()
	ent:Activate()
	ent:GetPhysicsObject():ApplyForceCenter(force)
	ent:GetPhysicsObject():EnableGravity(true)
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function ENT:Explode()
	if self.HasExploded then return end
	self.HasExploded = true
	util.BlastDamage(self, self:GetOwner(), self:GetPos(), 120, 160)	
	self:EmitSound("ut2004/weaponsounds/baseimpactandexplosions/BExplosion1.wav", 100, 100)
	
	ParticleEffect( "ut2004_flak_explosion", self:GetPos(), self:GetAngles() )
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	util.Effect("ut99_explight", effectdata)
	
	--local entforce = Vector(math.Rand(-1,1),math.Rand(-1,1),1) * 1500
	
	self:DoChunk(VectorRand() * 1500)
	self:DoChunk(VectorRand() * 1500)
	self:DoChunk(VectorRand() * 1500)
	self:DoChunk(VectorRand() * 1500)
	self:DoChunk(VectorRand() * 1500)
	
	self:Remove()		
end

function ENT:StartTouch()
	self:Explode()
end

end