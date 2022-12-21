AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Available" )
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel(self.model)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(true)
	self:SetAvailable(true)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 6)
end

function ENT:Think()
	if self.ReEnabled and CurTime() >= self.ReEnabled then
		self.ReEnabled = nil
		self:EmitSound("ut2004/weaponsounds/misc/item_respawn.wav")
		ParticleEffect( "ut2004_item_respawn", self:WorldSpaceCenter(), Angle(0,0,0), self )
		timer.Simple(0.5, function()
			if IsValid(self) then
				self:SetAvailable(true)
				self:DrawShadow(true)
			end
		end)
		/*local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(self:GetPos())
		util.Effect("entity_remove", effectdata, true, true)*/
	end
end

function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self:GetAvailable() then
		local ammoCount = ent:GetAmmoCount(self.AmmoType)
		if ammoCount >= self.MaxAmmo then return end
		self:SetAvailable(false)
		self:DrawShadow(false)
		self.ReEnabled = CurTime() + 25
		
		ent:EmitSound(self.PickupSound,85,100)
		if ammoCount < self.MaxAmmo then
			ent:SetAmmo(math.min(ammoCount + self.AmmoAmount, self.MaxAmmo), self.AmmoType)
		end
		
		ent:SetNW2Float("ut2004itempickup", CurTime())
	end
end