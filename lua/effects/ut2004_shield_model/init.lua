function EFFECT:Init(data)
	self.Owner = data:GetEntity()
	if !IsValid(self.Owner) then self:Remove() return end
	self:SetRenderBounds( Vector(-32, -32, -32), Vector(32, 32, 32))
	--self:SetAngles(data:GetAngles())
	self:SetModel("models/ut2004/weaponstaticmesh/shield.mdl")
	self:SetPos(self.Owner:GetShootPos())
	self:SetAngles(self.Owner:EyeAngles())
	--self.Size = 0
	--ParticleEffectAttach( "ut2004_shockcore1_inst", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function EFFECT:Think()	
	local wep = self.Owner:GetActiveWeapon()
	return IsValid(self.Owner) and IsValid(wep) and wep:GetClass() == "weapon_ut2004_shieldgun" and wep:GetAttack()
end

function EFFECT:Render()
	local ang = self.Owner:EyeAngles()
	local pos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 36 + ang:Right() * 8 + ang:Up() * -8
	self:SetupBones()
	self:SetPos(pos)
	self:SetAngles(ang)
	self:DrawModel()
end