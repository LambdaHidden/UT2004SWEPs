local exists = file.Exists("materials/sprites/ut99/exp1.vmt", "GAME")
EFFECT.mat = Material("sprites/ut99/exp1")

function EFFECT:Init(data)
	self.time = CurTime()+1
	self.Refract = 0
	self.Size = 48
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	self.Size = 128 * self.Refract^(0.2)
	
	if self.Refract >= .5 then return false end
	
	return true
end

function EFFECT:Render()
	local Pos = self:GetPos()

	render.SetMaterial( self.mat )
	if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(20-(self.time-CurTime())*20),0,9))
	end
	render.DrawSprite( Pos, self.Size, self.Size )
end