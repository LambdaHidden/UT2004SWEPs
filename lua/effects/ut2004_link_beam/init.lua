function EFFECT:Init(data)
	if !IsValid(data:GetEntity()) then self:Remove() return end
	
	local ent = data:GetEntity()
	self.Ent = ent
	self.Wep = ent:GetActiveWeapon()
	
	if LocalPlayer():GetViewEntity() == ent then
		--ParticleEffectAttach( "ut2004_link_beam", PATTACH_POINT_FOLLOW, ent:GetViewModel(), 1 )
		self.Particle = CreateParticleSystem( ent:GetViewModel(), "ut2004_link_beam", PATTACH_POINT_FOLLOW, 1 )
	else
		--ParticleEffectAttach( "ut2004_link_beam", PATTACH_POINT_FOLLOW, ent:GetActiveWeapon(), 1 )
		self.Particle = CreateParticleSystem( self.Wep, "ut2004_link_beam", PATTACH_POINT_FOLLOW, 1 )
	end
end

function EFFECT:Think()
	if !IsValid(self.Particle) then return end
	if IsValid(self.Wep.Link) then
		self.Particle:SetControlPointEntity(1, self.Wep.Link)
	else
		self.Particle:SetControlPoint(1, self.Wep:GetNWVector("LinkHitPos"))
	end
	
	if !self.Ent:KeyDown(IN_ATTACK2) then
		self.Particle:StopEmissionAndDestroyImmediately()
	end
	
	return self.Ent:KeyDown(IN_ATTACK2)
end

function EFFECT:Render()
	
end
