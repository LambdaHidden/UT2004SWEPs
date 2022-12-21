if (SERVER) then
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
end

ENT.Type			= "anim"
ENT.PrintName		= "UT2004 Grenade"
ENT.Author			= "Upset"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if SERVER then

function ENT:Initialize()
	self:SetModel("models/ut2004/vmweaponssm/playerweaponsgroup/vmgrenade.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	--self:PhysicsInitSphere(4, metal_bouncy)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:AddAngleVelocity(Vector(300,200,300))
		phys:SetDamping( 0.98, 1 )
		phys:EnableDrag(false)
		--phys:SetMass(4)
	end
	
	local eff = EffectData()
	timer.Create( self:EntIndex().."_beep", 2, 0, function() 
		eff:SetEntity(self)
		eff:SetOrigin(self:GetPos())
		if self.Owner then
			local plycol = self.Owner:GetPlayerColor()
			local col = ColorToHSV(plycol:ToColor())
			eff:SetColor(col)
		end
		util.Effect("ut2004_grenade_beep", eff)
		self:EmitSound("ut2004/assaultsounds/HumanShip/TargetCycle01.wav", 60, 100)
	end )
end

function ENT:OnRemove()
	if IsValid(self.Owner) and IsValid(self.OwnerGun) then
		table.RemoveByValue(self.OwnerGun.Grenades, self)
	end
	if timer.Exists(self:EntIndex().."_beep") then
		timer.Remove(self:EntIndex().."_beep")
	end
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
	end]]
	
	--if self:GetVelocity():Length() > 200 then
	if data.Speed > 200 then
		self:EmitSound("ut2004/weaponsounds/baseguntech/BGrenfloor1.wav")
		phys:SetMaterial("metal_bouncy")
	else
		phys:SetMaterial("metal")
		self:StopParticles()
		phys:SetVelocity(Vector(0,0,0))
	end
	--local impulse = -data.Speed * data.HitNormal * 7
	--phys:ApplyForceCenter(impulse)
end

function ENT:Think()
	
end

function ENT:Explode()
	--table.RemoveByValue(self.OwnerGun.Grenades, self)
	util.BlastDamage(self, self.Owner, self:GetPos(), 150, 100)
	self:EmitSound("ut2004/weaponsounds/baseimpactandexplosions/BExplosion3.wav", 100, 100)
	self:Remove()
	
	local spos = self:GetPos()
	local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-32), filter=self})
	util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)
end

function ENT:StartTouch(ent)
	if ( ent:IsValid() and ent != self.Owner and ent:IsPlayer() || ent:IsNPC() ) then
 		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetParent(ent)
		self:StopParticles()
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
	--util.Effect("ut2004_exp", effectdata)
	util.Effect("ut99_explight", effectdata)
	ParticleEffect( "ut2004_gl_explosion", self:GetPos(), self:GetAngles() )
end

function ENT:IsTranslucent()
	return true
end

end