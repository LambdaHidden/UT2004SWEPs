include('shared.lua')

function ENT:Initialize()
	ParticleEffectAttach( "ut2004_rocket_smoketrail", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function ENT:Draw()
	--self.Spin = self.Spin + FrameTime()*180
	--self:SetRenderAngles(self.Ang + Angle(0,0,self.Spin))
	--self:SetRenderAngles(self:GetAngles() + Angle(0,0,FrameTime()*180))
	self:DrawModel()
	
	if !cvars.Bool("ut2k4_lighting") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = self:GetPos()
		dynlight.Size = 64
		dynlight.Decay = 0
		dynlight.R = 255
		dynlight.G = 200
		dynlight.B = 0
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.1
end