EFFECT.Mat = Material("ut2004/XEffectMat/Shock/shock_ring_b")
EFFECT.Color = Color(255,255,255,255)

function EFFECT:Init(data)
	self:SetRenderBounds( Vector(-32, -32, -32), Vector(32, 32, 32))
	--self:SetAngles(data:GetAngles())
	self.Forward = data:GetNormal()
	--self:SetModel("models/ut2004/xeffects/shock_ring.mdl")
	self.Refract = 1
	self.Size = 0
end

function EFFECT:Think()
	if self.Refract >= 1.48 then return false end
	self.Refract = self.Refract + FrameTime()
	self.Size = self.Refract*168 - 168
	
	return true
end

function EFFECT:Render()	
	local col = 255 * -self.Refract * 2
	self.Color.a = col
	self:SetColor(self.Color)
	
	render.SetMaterial(self.Mat)
	render.DrawQuadEasy(self:GetPos(), self.Forward, self.Size, self.Size, self.Color)
	--self:SetModelScale(self.Size, 0)
	--self:DrawModel()
end