include('shared.lua')

function ENT:Initialize()
	ParticleEffectAttach( "ut2004_smoketrail_redeemer", PATTACH_POINT_FOLLOW, self, 1 )
end

--ENT.Spin = 0
function ENT:Draw()
	--self.Spin = self.Spin + FrameTime()*180
	--self:SetRenderAngles(self.Ang + Angle(0,0,self.Spin))
	if IsValid(self.Target) then
		self:SetAngles((self.Target:WorldSpaceCenter() - self:GetPos()):Angle())
	else
		self:SetRenderAngles(self:GetAngles() + Angle(0,0,FrameTime()*180))
	end
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