function EFFECT:Init(data)
	if !IsValid(data:GetEntity()) then self:Remove() return end
	
	local ent = data:GetEntity()
	if LocalPlayer():GetViewEntity() == ent then
		ParticleEffectAttach( "ut2004_shock_muzzle", PATTACH_POINT_FOLLOW, ent:GetViewModel(), 1 )
	else
		ParticleEffectAttach( "ut2004_shock_muzzle", PATTACH_POINT_FOLLOW, ent:GetActiveWeapon(), 1 )
	end
	
	self.Refract = 1
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	--self.Size = self.Refract*(10) - 10
	if self.Refract >= 1.2 then return false end
	
	return true
end

function EFFECT:Render()
	
end