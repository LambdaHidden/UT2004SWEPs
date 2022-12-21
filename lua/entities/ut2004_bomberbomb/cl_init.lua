include('shared.lua')

function ENT:Initialize()
	ParticleEffectAttach( "ut2004_smoketrail_redeemer", PATTACH_POINT_FOLLOW, self, 1 )
end

function ENT:Draw()
	self:SetRenderAngles(self:GetAngles() + Angle(0,0,FrameTime()*180))
	self:DrawModel()
end