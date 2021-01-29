function EFFECT:Init(data)
	if !IsValid(data:GetEntity()) then self:Remove() return end
	
	self:SetModel("models/ut2004/effects/shock_muzzleflash.mdl")
	
	self.Refract = 1
	
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	--self.Size = self.Refract*(10) - 10
	if self.Refract >= 1.2 then return false end
	
	return true
end

function EFFECT:Render()
	local col = 255 * -self.Refract * 3
	
	local Muzzle = self:GetTracerShootPos(self.Position, self.WeaponEnt, 1)
	if !self.WeaponEnt or !IsValid(self.WeaponEnt) then return end
	
	--self:SetRenderBoundsWS(Muzzle, self.Position)
	self:SetColor(Color(col,col,col))
	self:SetModelScale(self.Refract*2 - 1.5, 0)
	self:SetPos(Muzzle)
	self:SetAngles(self.WeaponEnt.Owner:EyeAngles())
	self:DrawModel()
end