include('shared.lua')

--killicon.Add("ut99_asmd", "vgui/ut99/asmd", Color(255, 80, 0, 255))

function ENT:Initialize()
	ParticleEffectAttach( "ut2004_shockcore", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function ENT:Draw()	
	if !cvars.Bool("ut2k4_lighting") then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = self:GetPos()
		dynlight.Size = 128
		dynlight.Decay = 128
		dynlight.R = 30
		dynlight.G = 50
		dynlight.B = 255
		dynlight.Brightness = 5
		dynlight.DieTime = CurTime()+.05
end