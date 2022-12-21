EFFECT.RingMat = Material("ut2004/XEffectMat/Shock/shock_ring_b")
EFFECT.RingColor = Color(127,255,127,255)

EFFECT.Flash1Mat = Material("ut2004/VMparticleTextures/LeviathanParticleEffects/rainbowSpikes")
EFFECT.Flash2Mat = Material("ut2004/VMparticleTextures/LeviathanParticleEffects/LEVsingBLIP")
EFFECT.CloudMat = Material("ut2004/VMparticleTextures/LeviathanParticleEffects/darkEnergy")

function EFFECT:Init(data)
	self:SetRenderBounds( Vector(-256, -256, -256), Vector(256, 256, 256))
	--self:SetAngles(data:GetAngles())
	self.Forward = data:GetNormal()
	--self:SetModel("models/ut2004/xeffects/shock_ring.mdl")
	self.InnerClock = 0
	self.Size = 0
	
	timer.Simple(0.1, function()
	local em = ParticleEmitter( self:GetPos() )
		for i = 0, 5 do
			local p = em:Add( self.CloudMat, self:GetPos() )
			if p then
				p:SetDieTime(0.35)
				p:SetStartAlpha(255)
				p:SetEndAlpha(0)
				p:SetRoll(math.Rand(0.6, 5))
				p:SetStartSize(32)
				p:SetEndSize(64)
				p:SetVelocity(Vector(math.random(-152, 152), math.random(-152, 152), math.random(-152, 152)))
			end
		end
		
		local p2 = em:Add( self.Flash2Mat, self:GetPos() )
		if p2 then
			p2:SetDieTime(0.3)
			p2:SetStartAlpha(255)
			p2:SetEndAlpha(0)
			--p2:SetRoll(math.Rand(0.6, 5))
			p2:SetStartSize(92)
			p2:SetEndSize(460)
		end
	em:Finish()
	end)
end

function EFFECT:Think()
	if self.InnerClock >= 1.5 then return false end
	self.InnerClock = self.InnerClock + FrameTime()
	
	return true
end

function EFFECT:Render()
	--RING
	local ringalpha = 255 - self.InnerClock*168
	local ringsize = self.InnerClock*512
	self.RingColor.a = ringalpha
	
	render.SetMaterial(self.RingMat)
	render.DrawQuadEasy(self:GetPos(), self.Forward, ringsize, ringsize, self.RingColor)
	
	
	--FLASH 1
	if self.InnerClock <= 0.1 then
		local em = ParticleEmitter( self:GetPos() )
			local p = em:Add( self.Flash1Mat, self:GetPos() )
			if p then
				p:SetDieTime(math.Rand(0.015, 0.05))
				p:SetStartAlpha(255)
				p:SetEndAlpha(127)
				p:SetRoll(math.Rand(0.6, 5))
				p:SetStartSize(math.random(64, 300))
				p:SetEndSize(math.random(64, 200))
			end
		em:Finish()
	end
end