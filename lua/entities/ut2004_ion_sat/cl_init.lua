include('shared.lua')

function ENT:Initialize()
	
end

function ENT:Draw()
	--self:SetRenderAngles(self:GetAngles() + Angle(0,0,FrameTime()*180))
	self:DrawModel()
end