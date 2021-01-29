include('shared.lua')

function ENT:Draw()
	--self:SetupBones()
	self:DrawModel()
	
	if !cvars.Bool("ut2k4_lighting") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = self:GetPos()
		dynlight.Size = 60
		dynlight.Decay = 0
		dynlight.R = 100
		dynlight.G = 255
		dynlight.B = 80
		dynlight.Brightness = 2
		dynlight.DieTime = CurTime()+.1
end

function ENT:IsTranslucent()
	return true
end