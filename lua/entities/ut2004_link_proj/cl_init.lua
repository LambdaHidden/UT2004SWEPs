include('shared.lua')

function ENT:Initialize()
	ParticleEffectAttach( "ut2004_link_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function ENT:Draw()	
	self:SetRenderAngles(self:GetAngles() + Angle(0,0,FrameTime()*360))
	self:DrawModel()
	
	if !cvars.Bool("ut2k4_lighting") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = self:GetPos()
		dynlight.Size = 80
		dynlight.Decay = 0
		dynlight.R = 100
		dynlight.G = 255
		dynlight.B = 80
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.1
end
 
function ENT:OnRemove()
end