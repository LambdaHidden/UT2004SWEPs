--local exists = file.Exists("materials/ut2004/xgameshaders/flak_flash.vmt", "GAME")
--EFFECT.mat = Material("ut2004/xgameshaders/flak_flash")

function EFFECT:Init(data) 
	self.time = CurTime()+1
	self.Refract = 0
	local col = data:GetStart()
	
	if !IsValid(data:GetEntity()) then return end
	local dynlight = DynamicLight(data:GetEntity():EntIndex())
		dynlight.Pos = data:GetOrigin()
		dynlight.Size = 80
		dynlight.Decay = 128
		dynlight.R = col[1]
		dynlight.G = col[2]
		dynlight.B = col[3]
		dynlight.Brightness = 1
		dynlight.DieTime = CurTime()+.1
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	--self.Size = 64 * self.Refract^(0.3)
	if self.Refract >= .2 then return false end	
	return true
end

function EFFECT:Render()
	
end