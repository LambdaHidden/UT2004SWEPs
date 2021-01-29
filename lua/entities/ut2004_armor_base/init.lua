AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.RespawnTime = 27

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 40
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel(self.model)
	--self:SetModelScale(0.4, 0) 
	self:SetMoveType(MOVETYPE_NONE)
	self:SetAngles(Angle(0,90,0))
	self:DrawShadow(true)
	self.Available = true
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 8)
end

function ENT:Think()
	if self.ReEnabled and CurTime() >= self.ReEnabled then
		self.ReEnabled = nil
		self.Available = true
		self:SetNoDraw(false)
		self:EmitSound("ut2004/weaponsounds/item_respawn.wav")
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(self:GetPos())
		util.Effect("entity_remove", effectdata, true, true)
	end
end

function ENT:StartTouch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self.Available then
		self.Available = false
		self:SetNoDraw(true)
		self.ReEnabled = CurTime() + self.RespawnTime
		
		ent:EmitSound(self.PickupSound,85,100)
		
		if ent.UT2K4UShield or ent:Armor() > self.MaxArmor then
			ent:SetArmor(math.min((ent:Armor()+self.Aamount), 150))
		else
			ent:SetArmor(math.min((ent:Armor()+self.Aamount), self.MaxArmor))
		end
		
		ent:SetNWFloat("ut2004itempickup", CurTime())
	end
end