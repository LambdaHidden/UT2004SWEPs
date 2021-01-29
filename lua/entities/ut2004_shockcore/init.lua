
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/XQM/Rails/gumball_1.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInitBox(Vector(-16,-16,-16),Vector(16,16,16))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:Wake()
		phys:SetMass(2)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:SetBuoyancyRatio(0)
	end
	self:SetRemoveDelay(10)
	self.HasHit = false
end

function ENT:SetRemoveDelay(flDelay)
	self.delayRemove = CurTime() +flDelay
end

function ENT:PhysicsUpdate(phys)
	if phys:GetVelocity():Length() < 10 then
		phys:EnableGravity(true)
	end
end

function ENT:PhysicsCollide(data)
	if self.HasHit then return end
	self.HasHit = true
	local owner = self:GetOwner()
	--local ang = IsValid(owner) and owner:IsPlayer() and owner:EyeAngles() or self:GetAngles()
	
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = data.HitPos + data.HitNormal * 8,
		filter = self
	})

	local effectdata = EffectData()
	effectdata:SetAngles(tr.HitNormal:Angle())
	effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
	--util.Effect("ut99_asmd_exp", effectdata)
	util.Effect("ut2004_shock_hitglow", effectdata)
	
	if IsValid(owner) then
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(owner)
		dmginfo:SetDamageType(DMG_SHOCK)
		dmginfo:SetDamage(82)
		util.BlastDamageInfo(dmginfo, data.HitPos + data.HitNormal, 70)
	end

	self:EmitSound("ut2004/weaponsounds/ShockRifleExplosion.wav", 75, 100)
	self:Remove()
end

function ENT:Think()
	if self.Combo then
		--util.BlastDamage(self, self.Owner, self:GetPos(), 300, 200)
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetDamageType(DMG_SHOCK)
		dmginfo:SetDamage(247)
		util.BlastDamageInfo(dmginfo, self:GetPos(), 256)
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetAngles(self.Owner:EyeAngles() + Angle(-90,0,0))
		util.Effect("ut2004_shock_combo", effectdata)
		--util.Effect("ut99_asmd_wavering", effectdata)
		self:EmitSound("ut2004/weaponsounds/ShockComboFire.wav", 120)
		self:Remove()
		local spos = self:GetPos()
		local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-64), filter=self})
		util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)
	end
	
	if !self.delayRemove || CurTime() < self.delayRemove then return end
	self.delayRemove = nil
	self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	if IsValid(attacker) and IsValid(inflictor) and attacker:IsPlayer() and inflictor:GetClass() == "weapon_ut2004_shock" and dmginfo:GetDamageType() == DMG_SHOCK then
		self.Owner = attacker
		self.Inflictor = inflictor
		if !cvars.Bool( "ut2k4_unlimitedammo" ) then
			inflictor:TakePrimaryAmmo(4)
		end
		self.Combo = true
	end
end