EFFECT.EndMat 		= Material(  "ut2004/effects/shock_sparkle" )
EFFECT.BeamMat 		= Material(  "ut2004/effects/ShockBeamTex" )

function EFFECT:Init(data)
	if !IsValid(data:GetEntity()) then self:Remove() return end
	self:SetAngles(data:GetAngles())
	self:SetModel("models/ut2004/effects/shock_coil.mdl")
	self.Refract = 1
	
	self.EndPos = data:GetOrigin()
	self.StartPos = self:GetTracerShootPos(data:GetStart(), data:GetEntity(), 1)
	
	self.Forward = (self.EndPos-self.StartPos):GetNormal()
	self.Angles = self.Forward:Angle()
	self.Distance = self.EndPos:Distance(self.StartPos)
	
	self:SetPos(self.StartPos)
	self:SetAngles(self.Angles)
	--self.Size = 0
	--ParticleEffectAttach( "ut2004_shockcore1_inst", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	if cvars.Bool("ut2k4_lighting") then
		local dynlight = DynamicLight(data:GetEntity())
		dynlight.Pos = self.EndPos
		dynlight.Size = 90
		dynlight.Decay = 90
		dynlight.R = 60
		dynlight.G = 50
		dynlight.B = 255
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.4
	end
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	--self.Size = self.Refract*(10) - 10
	if self.Refract >= 1.5 then return false end
	
	return true
end

function EFFECT:Render()
	local col = 255 * -self.Refract * 2
	
	--self:SetModelScale(self.Size, 0)
	self:SetColor(Color(col,col,col,col))
	
	render.SetMaterial(self.EndMat);
	render.DrawSprite( self.StartPos, 20, 20, Color(col,col,col,col) )
	render.SetMaterial(self.BeamMat);
	render.DrawBeam( self.StartPos, self.EndPos, 10, 0, 1, Color(col,col,col,col) )
	
	for i = 0, self.Distance / 45 do
		self:SetupBones()
		self:SetPos(self.StartPos + self.Forward*i*45)
		self:DrawModel()
	end
end