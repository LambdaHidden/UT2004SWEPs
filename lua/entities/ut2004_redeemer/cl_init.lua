include('shared.lua')

function ENT:Initialize()
	ParticleEffectAttach( "ut2004_smoketrail_redeemer", PATTACH_POINT_FOLLOW, self, 1 )
end

function ENT:Draw()	
	if self.Owner:GetViewEntity() != self then
		self:SetRenderAngles(self:GetAngles() + Angle(0,0,FrameTime()*90))
	end
	self:DrawModel()
	
	if !cvars.Bool("ut2k4_lighting") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = self:GetPos()
		dynlight.Size = 128
		dynlight.Decay = 0
		dynlight.R = 255
		dynlight.G = 200
		dynlight.B = 0
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.1
end
 
function ENT:OnRemove()
end