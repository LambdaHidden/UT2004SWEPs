include('shared.lua')

function ENT:Initialize()
	ParticleEffectAttach( "ut2004_smoketrail_cheap", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
	/*
	local Pos = self:GetPos()
	
	local emitter = ParticleEmitter(Pos)

	self.particle = emitter:Add("sprites/ut99/fglow", Pos)

	if (self.particle) then
		self.particle:SetLifeTime(0) 
		self.particle:SetDieTime(.5)
		self.particle:SetStartAlpha(255)
		self.particle:SetEndAlpha(0)
		self.particle:SetStartSize(8) 
		self.particle:SetEndSize(6)
		self.particle:SetAngles(Angle(0,0,0))
		self.particle:SetAngleVelocity(Angle(.1,0,0)) 
		self.particle:SetRoll(math.Rand(0, 360))
		self.particle:SetColor(255,255,255,255)
		self.particle:SetGravity(Vector(0,0,0))
		self.particle:SetAirResistance(0)
		self.particle:SetCollide(true)
	end

	emitter:Finish()*/
end

function ENT:Draw()
	self:DrawModel()
end
/*
function ENT:Think()
	local Pos = self:GetPos() -self:GetForward() *1.1
	self.particle:SetPos(Pos)
end

function ENT:OnRemove()
	self.particle:SetDieTime(0)
end
*/