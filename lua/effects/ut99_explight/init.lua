function EFFECT:Init(data)
	if !cvars.Bool("ut2k4_lighting") then return end
	local dynlight = DynamicLight(0)
		dynlight.Pos = data:GetOrigin()
		dynlight.Size = 256
		dynlight.Decay = 340
		dynlight.R = 255
		dynlight.G = 160
		dynlight.B = 55
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.5
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end