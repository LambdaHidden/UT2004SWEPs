if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type			= "anim"
ENT.PrintName		= "UT2004 Flak Chunk"
ENT.Author			= "Upset"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

--local mat = "models/items/ut99/Chunk"

if SERVER then

function ENT:Initialize()
	self:SetModel("models/ut2004/weaponstaticmesh/flakchunk.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInitSphere(2, "metal_bouncy")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	
	util.SpriteTrail( self, 0, Color( 255, 200, 0 ), false, 15, 13, .15, 0.125, "trails/laser.vmt" )
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetDamping( math.Rand(0.28, 0.32), 0.25 )
		phys:SetBuoyancyRatio(1)
	end
	--self:SetMaterial(mat)
	
	self:SetRemoveDelay(3)
end

function ENT:SetRemoveDelay(flDelay)
	self.delayRemove = CurTime() +flDelay
end

function ENT:Think()
	if !self.delayRemove || CurTime() < self.delayRemove then return end
	self.delayRemove = nil
	self:Remove()
end

function ENT:StartTouch(ent)
	--if ent:IsValid() and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() or ent:Health() > 0) then
	if ent:IsValid() and ent:Health() > 0 then
		if self:GetVelocity():Length() > 500 then
			ent:TakeDamage(24, self.Owner)
		end
 		--self:EmitSound("weapons/ut99/ChunkHit.wav")
		self:Remove()
	end
end

end

function ENT:PhysicsCollide(data,phys)
	
	local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal	
	local trace = {}
	trace.start = endpos
	trace.endpos = start
	trace.filter = self
	local tr = util.TraceLine(trace)
	
	if tr.HitWorld then
		self:SetOwner(nil)
		self.Owner = self:GetVar("owner",Entity(1))
		phys:ApplyForceCenter(self:GetVelocity()*-0.2)
		--phys:SetDamping( 0.8, 0.8 )
	end
	
	if self:GetVelocity():Length() < 1100 then
		--self:SetMoveType(MOVETYPE_NONE)
		phys:SetMaterial( "metal" )
		phys:SetVelocityInstantaneous(Vector(0,0,0))
	end
	phys:EnableGravity(true)
	if !(data.HitEntity:Health() > 0) then
		if data.Speed > 640 then
			self:ImpactEffect(tr)
		end
		--self:EmitSound("weapons/ut99/Hit" .. math.random(1,3) .. ".wav")
	end
end

function ENT:ImpactEffect(tr)
	local e = EffectData()
	e:SetOrigin(tr.HitPos)
	e:SetStart(tr.StartPos)
	e:SetSurfaceProp(tr.SurfaceProps)
	e:SetDamageType(DMG_BULLET)
	e:SetHitBox(tr.HitBox)
	if CLIENT then
		e:SetEntity(tr.Entity)
	else
		e:SetEntIndex(tr.Entity:EntIndex())
	end
	util.Effect("Impact", e)
end