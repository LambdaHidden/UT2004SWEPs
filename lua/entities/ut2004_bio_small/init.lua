AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/ut2004/projectiles/biogoo.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:ResetSequence(self:LookupSequence("fly"))
end

function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() +flDelay
end

ENT.hastouched = nil

function ENT:PhysicsCollide(data,phys)

	if data.HitEntity:GetClass() == "ut2004_bio" then return end
	
	if (data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() || data.HitEntity:IsNextBot()) and data.HitEntity !=self.Owner then
		self:Explode()
		return
	end
	if self.hastouched then return end
	
	if (data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() || data.HitEntity:IsNextBot() || data.HitEntity:GetClass() == "ut2004_bio") then return end
	
	self:SetPos(data.HitPos)
	self:SetAngles(data.HitNormal:Angle())
	
	if data.HitEntity:GetSolid() == SOLID_VPHYSICS then
		self:SetParent(data.HitEntity)
	end
	
	self:SetMoveType(MOVETYPE_NONE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Sleep()
	end
	
	self:SetExplodeDelay(3)
	self:ResetSequence(self:LookupSequence("hit"))
	timer.Simple(self:SequenceDuration(), function()
		if IsValid(self) then
			--print(data.HitNormal)
			if data.HitNormal.z > -0.75 then
				self:ResetSequence(self:LookupSequence("slide"))
			end
			if data.HitNormal.z > 0.75 then
				self:ResetSequence(self:LookupSequence("drip"))
				
				timer.Simple(self:SequenceDuration(), function()
					self:ResetSequence(self:LookupSequence("fly"))
					self:SetMoveType(MOVETYPE_VPHYSICS)
					self:SetParent(nil)
					local phys = self:GetPhysicsObject()
					if phys:IsValid() then
						phys:Wake()
					end
					self.hastouched = false
					self:SetExplodeDelay(3)
					--self:SetAngles(Angle(180, 0, 0))
				end)
				
			end
		end
	end)
	
	self:EmitSound("ut2004/weaponsounds/BBioRifleGoo"..math.random(1,2)..".wav")
	self.hastouched = true
end

function ENT:Think()
	self:NextThink(CurTime())
	if !self.delayExplode || CurTime() < self.delayExplode then return true end
	self.delayExplode = nil
	self:Explode()
	return true
end

function ENT:Explode()
	local damage = 35
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self:GetOwner())
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_RADIATION)
	dmginfo:SetDamage(damage)
	util.BlastDamageInfo(dmginfo, self:GetPos(), 50)

	ParticleEffect( "ut2004_bio_explode", self:GetPos(), self:GetAngles() )
	self:EmitSound("ut2004/weaponsounds/BBioRifleGoo"..math.random(1,2)..".wav")
	self:Remove()
end

function ENT:PhysicsUpdate(phys)
	if self:WaterLevel() > 2 then
		self:Remove()
	end
end