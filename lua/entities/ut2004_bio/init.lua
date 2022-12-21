AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.BaseDamage		= 20
ENT.Damage			= 19
ENT.DamageRadius 	= 72

ENT.RestTime		= 2.25
ENT.DripTime		= 1.8
ENT.MaxGoopLevel	= 5
ENT.GoopLevel		= 1
ENT.GoopVolume		= 1
--ENT.Speed			= 1222 --?
ENT.GoblingSpeed	= 122 --
ENT.LifeSpan		= 20.0

ENT.ShouldMerge		= true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State") -- 0 is Flying, 1 is OnGround, 2 is Shriveling.
	self:NetworkVar("Float", 0, "DrawScale")
end

function ENT:Initialize()
	self:SetModel("models/ut2004/xweapons_rc/goopmesh.mdl")
	--self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	
	--self:SetTrigger(true)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(2)
		phys:EnableDrag(false)
	end
	self:ResetSequence(self:LookupSequence("fly"))
	self:SetState(0)
	if self:GetDrawScale() == 0 then self:SetDrawScale(1) end
	self.Rand3 = math.random(0,3)
	self.LifeTime = CurTime() + self.LifeSpan
end


function ENT:LandedRest(adjust)
	if adjust then
		--if timer.Exists(self:EntIndex().."GoopRest") then
			timer.Adjust(self:EntIndex().."GoopRest", self.RestTime)
		--end
	else
		timer.Create(self:EntIndex().."GoopRest", self.RestTime, 1, function()
			if !IsValid(self) then return end
			if self.ShouldDrip then
				self.ShouldDrip = false
				--self:SetCollisionSize(1)
				self:SetParent(nil)
				--self:SetPos(self:GetPos() - self:GetForward() * self.GoopVolume*self:GetModelScale())
				self:SetPos(self:GetPos() - self:GetForward() * self.GoopVolume*6)
				--self:SetAngles(Angle(0,0,0))
				self:ResetSequence(self:LookupSequence("fly"))
				local phys = self:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableMotion(true)
					--phys:EnableGravity(true)
					phys:Wake()
				end
				self:SetState(0)
			else
				self:BlowUp()
			end
		end)
	end
end

function ENT:LandedSlide()
	--debugoverlay.Axis( self:GetPos(), self:GetAngles(), 32, 2, true )
	if !timer.Adjust(self:EntIndex().."GoopSlide", self.DripTime) then
		timer.Create(self:EntIndex().."GoopSlide", self.DripTime, 1, function()
			if !IsValid(self) then return end
			local fwrd = -self:GetForward()
			if fwrd.z < -0.7 then
				self:ResetSequence(self:LookupSequence("drip"))
				self:EmitSound("ut2004/weaponsounds/baseguntech/BBioRifleDrip.wav")
				self:SetState(2)
				self.ShouldDrip = true
			elseif fwrd.z < 0.5 then
				self:ResetSequence(self:LookupSequence("slide"))
			end
		end)
	end
end


function ENT:HitWall(data)
	self:Landed(data)
	if data.HitEntity ~= nil then
		if not data.HitEntity:IsWorld() then
			self:SetParent(data.HitEntity)
		end
		--self.ShouldDrip = true
	else
		self:BlowUp()
	end
end

function ENT:PhysicsCollide(data, phys)
	if self:GetState() == 0 then
		if data.HitEntity:GetClass() == "ut2004_bio" then
			--if !(data.HitEntity.Owner) or (data.HitEntity.Owner != self.Owner and self.Owner != self) then
				if data.HitEntity.ShouldMerge then
					data.HitEntity:MergeWithGlob(self.GoopLevel) -- This could cause an infinite loop, someone at Epic said.
					self:Remove()
				else
					self:BlowUp()
				end
			--end
		elseif data.HitEntity.Health and data.HitEntity:Health() > 0 then
			self:BlowUp()
		else
			self:HitWall(data)
		end
	elseif self:GetState() > 0 then
		if data.HitEntity.Health and data.HitEntity:Health() > 0 and data.HitEntity != self:GetParent() then
			self:BlowUp()
		end
	end
end



function ENT:BlowUp()
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(self.Owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(DMG_RADIATION)
	dmginfo:SetDamage(self.BaseDamage + self.Damage * self.GoopLevel)
	util.BlastDamageInfo(dmginfo, self:GetPos(), self.DamageRadius * self.GoopVolume)
	
	ParticleEffect( "ut2004_bio_explode", self:GetPos(), self:GetAngles() )
	self:EmitSound("ut2004/weaponsounds/biorifle/BBioRifleGoo"..math.random(1,2)..".wav")
	self:Remove()
end

function ENT:SetCollisionSize(scale)
	self:SetModelScale(scale)
	self:Activate()
	self:SetModelScale(self:GetDrawScale())
end

function ENT:Think()
	if CurTime() > self.LifeTime then self:BlowUp() end
	
	self:NextThink(CurTime())
	return true
end