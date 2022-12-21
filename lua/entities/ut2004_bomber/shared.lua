if (SERVER) then
AddCSLuaFile( "shared.lua" )
end

ENT.Type			= "anim"
ENT.PrintName		= "UT2004 Bomber"
ENT.Author			= "Hidden"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

--ENT.State = 0
--ENT.TargetCenter = nil
ENT.TimeToDeparture = 0
ENT.LastBombDropped = 0

ENT.Speed			= 6111
ENT.MinSpeed		= 1024
ENT.MaxSpeed		= 6111
--ENT.BombRange		= 3055
ENT.BombRangeSqr	= 9333025

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State") -- 0 is heading to target, 1 is bombing, 2 is going away, -1 is destroyed.
	self:NetworkVar("Vector", 0, "TargetCenter")
	--self:NetworkVar("Float", 0, "LastBombDropped")
end

function ENT:Initialize()
	self:SetModel("models/ut2004/onsfullanimations/bomber.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		--phys:SetMass(1000)
		phys:EnableGravity(false)
	end
	
	self:SetState(0)
	self:SetHealth(150)
	--self:SetTargetCenter(Vector(0,0,0))
	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	effect:SetNormal(self:GetForward())
	util.Effect("ut2004_bomber_warp", effect)
	
	if SERVER then self:SetLagCompensated(true) end
end

function ENT:Think()
	if self:Health() <= 0 then return end
	
	local targetdist = self:GetPos():DistToSqr(self:GetTargetCenter())
	self.Speed = Lerp((targetdist / self.BombRangeSqr/2)-1, self.MinSpeed, self.MaxSpeed)
	
	local phys = self:GetPhysicsObject()
	if phys then
		phys:SetVelocity(self:GetForward()*self.Speed)
	end
	
	
	if self:GetState() == 0 then
		self:SetAngles(LerpAngle( 0.1, self:GetAngles(), (self:GetTargetCenter() - self:GetPos()):Angle() ))
		if targetdist < self.BombRangeSqr then
			self:SetState(1)
		end
	elseif self:GetState() == 1 then
		if self.LastBombDropped + 0.33 <= CurTime() then
			if SERVER then self:DropBomb() end
			self.LastBombDropped = CurTime()
			--self:SetLastBombDropped(CurTime())
		end
		if self:GetPos():DistToSqr(self:GetTargetCenter()) > self.BombRangeSqr then
			self.TimeToDeparture = CurTime() + 5
			self:SetState(2)
		end
	elseif self:GetState() == 2 and self.TimeToDeparture < CurTime() then
		if SERVER then self:Remove() end
	end
end

function ENT:DropBomb()
	local bomb = ents.Create("ut2004_bomberbomb")
	bomb:SetOwner(self:GetOwner())
	bomb:SetPos(self:GetAttachment(1).Pos - Vector(0,0,128))
	bomb:SetAngles(Angle(90,0,0))
	bomb:Spawn()
	bomb:Activate()
	local phys = bomb:GetPhysicsObject()
	if phys then
		phys:SetVelocity(Vector(0,0,-1024))
	end
end

function ENT:Bomb(BombTargetCenter)
	self:SetTargetCenter(BombTargetCenter)
	self:SetState(0)
end

function ENT:OnTakeDamage(dmg)
	if self:Health() <= 0 then return end
	self:SetHealth(self:Health() - dmg:GetDamage())
	
	if self:Health() <= 0 then
		self:Destroy()
	end
end

function ENT:Destroy()
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(true)
	end
	self:SetSkin(2)
	self:Ignite(10)
	self:SetState(-1)
end


function ENT:PhysicsCollide(data)
	if data.HitEntity:IsWorld() then
		if self:GetState() == -1 then
			self:SetState(-2)
			
			ParticleEffect( "ut2004_redeemer_exp", self:GetPos(), self:GetAngles() )
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetScale(512)
			timer.Simple(0.75, function() 
				util.Effect("ut2004_redeemer_exp", effectdata, true, true)
			end)
			self:EmitSound("ut2004/weaponsounds/misc/redeemer_explosionsound.wav", 500)
			
			self:SetNoDraw(true)
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			self:SetMoveType(MOVETYPE_NONE)
			
			local own = self:GetOwner()
			local pos = self:GetPos()
			local DamageRadius = 787
			local i = 1
			
			util.ScreenShake( pos, 50, 255, 2, 2048 )
			util.BlastDamage(self, own, pos, DamageRadius*0.125, 250 )
			timer.Simple(0.5, function() 
				if IsValid(self) then
					timer.Create(self:EntIndex().."redeemerexplosion", 0.2, 4, function() 
						if IsValid(self) then
							i = i+1
							util.BlastDamage(self, own, pos, DamageRadius*i*0.25, 250 )
							if i == 4 and SERVER then self:Remove() end
						end
					end)
				end
			end)
		else
			if SERVER then self:Remove() end
			local effect = EffectData()
			effect:SetOrigin(data.HitPos)
			effect:SetNormal(-data.HitNormal)
			util.Effect("ut2004_bomber_warp", effect)
		end
	end
end

function ENT:Draw()
	--self:SetRenderOrigin(self:GetPos() + self:GetVelocity())
	self:DrawModel()
end

function ENT:OnRemove()
	
end