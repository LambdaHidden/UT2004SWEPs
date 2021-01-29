include('shared.lua')

function ENT:Initialize()
	local Pos = self:GetPos()
	
	local emitter = ParticleEmitter(Pos)

	self.particle = emitter:Add("sprites/light_glow02_add", Pos)

	if (self.particle) then
		self.particle:SetLifeTime(0) 
		self.particle:SetDieTime(.5)
		self.particle:SetStartAlpha(220)
		self.particle:SetEndAlpha(0)
		self.particle:SetStartSize(16) 
		self.particle:SetEndSize(8)
		self.particle:SetAngles(Angle(0,0,0))
		self.particle:SetAngleVelocity(Angle(.1,0,0)) 
		self.particle:SetRoll(math.Rand(0, 360))
		self.particle:SetColor(255,200,0,255)
		self.particle:SetGravity(Vector(0,0,0))
		self.particle:SetAirResistance(0)
		self.particle:SetCollide(true)
	end

	emitter:Finish()	
	
	self.time = CurTime()+1
end

function ENT:Draw()
	--Material(mat):SetInt("$frame", math.Clamp(math.floor(7-(self.time-CurTime())*7),0,11))
	self:DrawModel()
end

function ENT:Think()
	local Pos = self:GetPos()
	self.particle:SetPos(Pos)
end

function ENT:OnRemove()
	if !game.SinglePlayer() then
		self.particle:SetDieTime(0)
	end
end