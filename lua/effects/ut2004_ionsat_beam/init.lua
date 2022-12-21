EFFECT.Beam2Mat = Material("ut2004/XEffectMat/Ion/Ion_beam") -- "cable/redlaser" "sprites/laserbeam"
EFFECT.CoreMat = Material("ut2004/XEffectMat/Shock/shock_core")
local whitebeamcol = Color(255,255,255,16)

function EFFECT:Init(data)
	self:SetPos(data:GetOrigin())
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.mins = Vector(math.min(data:GetOrigin().x, data:GetStart().x), math.min(data:GetOrigin().y, data:GetStart().y), math.min(data:GetOrigin().z, data:GetStart().z))
	self.maxs = Vector(math.max(data:GetOrigin().x, data:GetStart().x), math.max(data:GetOrigin().y, data:GetStart().y), math.max(data:GetOrigin().z, data:GetStart().z))
	self:SetRenderBoundsWS( self.mins, self.maxs )
	
	self:EmitSound("ut2004/weaponsounds/tagrifle/IonCannonBlast.wav", 200)
	
	self.InnerClock = 0.0
end

function EFFECT:Think()
	self.InnerClock = self.InnerClock + FrameTime()
	
	return self.InnerClock <= 1.25
end

function EFFECT:Render()
	render.SetColorMaterial()
	render.DrawBeam(self.StartPos, self.EndPos, 64, 0, 1, whitebeamcol)
	
	local corepos = LerpVector(math.Clamp(self.InnerClock*2,0,1), self.StartPos, self.EndPos)
	
	render.SetMaterial(self.Beam2Mat)
	render.DrawBeam(self.StartPos, corepos, 48, 0, 1, color_white)
	
	render.SetMaterial(self.CoreMat)
	render.DrawSprite(corepos, 128, 128)
end