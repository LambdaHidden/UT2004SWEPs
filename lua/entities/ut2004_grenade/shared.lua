AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

ENT.Type			= "anim"
ENT.PrintName		= "UT2004 Grenade"
ENT.Author			= "Upset"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if SERVER then

function ENT:Initialize()
	self:SetModel("models/ut2004/weaponstaticmesh/grenademesh.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:AddAngleVelocity(Vector(math.random(-2,2) *300,200,math.random(-1,1) *300))
		phys:SetDamping( 0.15, 0.75 )
	end
end

function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() +flDelay
end

function ENT:OnRemove()
end

function ENT:PhysicsCollide(data,phys)
	--[[local start = data.HitPos + data.HitNormal
    local endpos = data.HitPos - data.HitNormal	
	local trace = {}
	trace.start = endpos
	trace.endpos = start
	trace.filter = self
	local tr = util.TraceLine(trace)
	
	if tr.HitWorld then
		self:SetOwner(nil)
		self.Owner = self:GetVar("owner",Entity(1))
	end
	
	if data.HitEntity:IsWorld() then
		self:SetOwner(nil)
		self.Owner = self:GetVar("owner",Entity(1)) -- Why are we removing the reference to the owner?
	end]]
	
	--if self:GetVelocity():Length() > 196 then
	if data.Speed > 196 then
		self:EmitSound("ut2004/weaponsounds/baseguntech/BGrenfloor1.wav")
		phys:SetMaterial("metal_bouncy")
	else
		phys:SetMaterial("metal")
		phys:SetVelocity(Vector(0,0,0))
	end
	--local impulse = -data.Speed * data.HitNormal * 7
	--phys:ApplyForceCenter(impulse)
end

function ENT:Think()
	if !self.delayExplode || CurTime() < self.delayExplode then return end
	--self.delayExplode = nil
	self:Explode()
end

function ENT:Explode()
	util.BlastDamage(self, self.Owner, self:GetPos(), 150, 70)
	self:EmitSound("ut2004/weaponsounds/baseimpactandexplosions/BExplosion3.wav", 100, 100)
	self:Remove()
	
	local spos = self:GetPos()
	local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-32), filter=self})
	util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)
end

function ENT:StartTouch(ent)
	if ( ent:IsValid() and ent:IsPlayer() || ent:IsNPC() ) then
 		self:Explode()
	end
end

function ENT:EndTouch()
end

function ENT:Touch()
end

end

if CLIENT then
--killicon.Add( "ut2004_grenade", "vgui/ut99/eight", Color( 255, 80, 0, 255 ) )
function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	util.Effect("ut2004_exp", effectdata)
	util.Effect("ut99_explight", effectdata)
	ParticleEffect( "ut2004_flak_explosion1", self:GetPos(), self:GetAngles() )
end

function ENT:IsTranslucent()
	return true
end

end