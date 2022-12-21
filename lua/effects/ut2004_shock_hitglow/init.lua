EFFECT.GlowMat 		= Material( "particle/particle_glow_04" )

function EFFECT:Init(data)
	self:SetRenderBounds( Vector(-8, -8, -8), Vector(8, 8, 8))
	self.Origin = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.DotColor = Color(128,128,255,255)
	self.Refract = 1
	--self.Refract2 = 1
	ParticleEffectAttach( "ut2004_shockcore_impact", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function EFFECT:Think()
	if self.Refract >= 2.25 then return false end --3.75
	self.Refract = self.Refract + FrameTime()
	
	return true
end

function EFFECT:Render()
	--local col2 = 640 - 168*self.Refract2
	self.DotColor.a = 640 - 168*self.Refract
	render.SetMaterial(self.GlowMat)
	render.DrawQuadEasy( self.Origin, self.Normal, 48, 48, self.DotColor, 0 ) --Color(128,128,255,col2)
end