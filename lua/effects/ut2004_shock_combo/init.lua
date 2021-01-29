EFFECT.Mat1 = Material("ut2004/effects/shock_spheretex")
--EFFECT.AutomaticFrameAdvance = true

function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	if cvars.Bool("ut2k4_lighting") then
		local dynlight = DynamicLight(0)
		dynlight.Pos = data:GetOrigin()
		dynlight.Size = 200
		dynlight.Decay = 200
		dynlight.R = 50
		dynlight.G = 80
		dynlight.B = 255
		dynlight.Brightness = 7
		dynlight.DieTime = CurTime()+.4
	end

	--self:SetModel("models/ut2004/effects/shock_vortex.mdl")
	--self:SetMaterial(self.Mat)

	self.Time = 0
	self.Size2 = 0
	ParticleEffectAttach( "ut2004_shockcore_explosion", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function EFFECT:Think()
	self.Time = self.Time + FrameTime()
	
	self.Size2 = 10 - self.Time*10
	self.Size2 = math.Clamp(self.Size2, 0, 5)
	--self.Size = math.max(self.Time * 40 - 5, 0)
	return self.Time < 1.0
end

function EFFECT:Render()
	
	render.SetMaterial(self.Mat1)
	render.DrawSphere( self:GetPos(), 16*self.Size2, 16, 8, Color( 255, 255, 255 ) )
	local matrix = Matrix()
	matrix:SetTranslation(Vector(self.Time*2, self.Time*0.6, 0))
	matrix:SetScale(Vector(0.5, 0.5 ,0))
	self.Mat1:SetMatrix( "$basetexturetransform", matrix)
	
	--self:SetRenderAngles(LocalPlayer():EyeAngles()*-1)
	--self:ResetSequence( 1 )
	--self:DrawModel()
end