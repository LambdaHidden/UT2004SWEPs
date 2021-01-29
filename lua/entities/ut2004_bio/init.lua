AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/ut2004/projectiles/biogoo.mdl")
	--self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	
	--self:SetTrigger(true)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableDrag(false)
		phys:SetMass(1)
		--phys:SetDamping(0,0)
	end
	self:ResetSequence(self:LookupSequence("fly"))
end

function ENT:SetExplodeDelay(flDelay)
	self.delayExplode = CurTime() +flDelay
end

ENT.hastouched = nil

function ENT:PhysicsCollide(data,phys)

	if (data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() || data.HitEntity:IsNextBot()) and data.HitEntity !=self.Owner then
		self:Explode()
	end
	if self.hastouched then return end
	
	if (data.HitEntity:IsNPC() || data.HitEntity:IsPlayer() || data.HitEntity:IsNextBot() || data.HitEntity:GetClass() == "ut2004_bio" || data.HitEntity:GetClass() == "ut2004_bio_small") then return end
	
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
			if data.HitNormal.z > -0.75 then
				self:ResetSequence(self:LookupSequence("slide"))
			end
			if data.HitNormal.z > 0.75 then
				self:ResetSequence(self:LookupSequence("drip"))
				self:EmitSound("ut2004/weaponsounds/BBioRifleDrip.wav")
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
				end)
				
			end
		end
	end)
	
	if self:GetModelScale() > 1.5 then
		for i = 1, self:GetModelScale()*3 do
			self:SplitBlob()
		end
	end
	
	self:EmitSound("ut2004/weaponsounds/BBioRifleGoo"..math.random(1,2)..".wav")
	
	self.hastouched = true
end

function ENT:StartTouch(ent)
	--print("StartTouch")
	if ent:GetClass() == "ut2004_bio" and ent.hastouched then 
		if ent:GetModelScale() < 1.8 then
			ent:SetExplodeDelay(3)
			ent:SetModelScale(math.Clamp(ent:GetModelScale()+0.2, 0.2, 2.2))
			ent:PhysicsInit(SOLID_VPHYSICS)
			ent:SetMoveType(MOVETYPE_NONE)
			ent:ResetSequence(self:LookupSequence("hit"))
			/*
			timer.Simple(ent:SequenceDuration(), function()
				if IsValid(ent) then
					if ent:GetForward().z > -0.75 then
						ent:ResetSequence(ent:LookupSequence("slide"))
					end
				end
			end)
			*/
	
			self:Remove()
		else
			ent:SplitBlob()
			ent:SplitBlob()
			ent:PhysicsInit(SOLID_VPHYSICS)
			ent:SetMoveType(MOVETYPE_NONE)
			self:Remove()
		end
		return 
	end
end

function ENT:Think()
	self:NextThink(CurTime())
	if !self.delayExplode || CurTime() < self.delayExplode then return true end
	self.delayExplode = nil
	self:Explode()
	return true
end

function ENT:Explode()
	local damage = math.Round((self:GetModelScale()-0.8)*175)
	--print(damage)
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self.Owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_RADIATION)
	dmginfo:SetDamage(damage)
	util.BlastDamageInfo(dmginfo, self:GetPos(), 50)

	ParticleEffect( "ut2004_bio_explode", self:GetPos(), self:GetAngles() )
	self:EmitSound("ut2004/weaponsounds/BBioRifleGoo"..math.random(1,2)..".wav")
	self:Remove()
end

function ENT:SplitBlob()
	self:ResetSequence(self:LookupSequence("hit"))
	self:SetModelScale(1.6)
	
	local ent = ents.Create("ut2004_bio_small")
	local pos = self:GetPos() + self:GetForward() * -16
	local ang = pos:Angle()
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetOwner(self.Owner)
	ent:SetExplodeDelay(4)
	ent:SetModelScale(1.2, 0)
	ent:Spawn()
	ent:Activate()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(VectorRand() *100)
	end
end

function ENT:PhysicsUpdate(phys)
	if self:WaterLevel() > 2 then
		self:Remove()
	end
end