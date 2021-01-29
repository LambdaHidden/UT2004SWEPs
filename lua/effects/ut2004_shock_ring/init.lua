function EFFECT:Init(data)
	self:SetAngles(data:GetAngles() + Angle(90,0,0))
	self:SetModel("models/ut2004/effects/shock_ring.mdl")
	self.Refract = 1
	self.Size = 0
end

function EFFECT:Think()
	if self.Refract >= 1.48 then return false end
	self.Refract = self.Refract + FrameTime()
	self.Size = self.Refract*(10) - 10
	
	return true
end

function EFFECT:Render()	
	local col = 255 * -self.Refract * 2
	self:SetModelScale(self.Size, 0)
	self:SetColor(Color(col,col,col,col))
	self:DrawModel()
end