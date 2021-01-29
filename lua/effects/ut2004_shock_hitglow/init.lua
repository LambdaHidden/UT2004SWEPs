EFFECT.GlowMat 		= Material(  "particle/particle_glow_04" )

function EFFECT:Init(data)
	self.Origin = data:GetOrigin()
	self.Normal = data:GetAngles():Forward()
	self.Refract = 1
	self.Refract2 = 1
	ParticleEffectAttach( "ut2004_shockcore_impact", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
end

function EFFECT:Think()
	if self.Refract2 >= 3.75 then self:Remove() end
	self.Refract2 = self.Refract2 + FrameTime()
	
	return true
end

function EFFECT:Render()
	local col2 = 640 - 168*self.Refract2
	render.SetMaterial(self.GlowMat)
	render.DrawQuadEasy( self.Origin, self.Normal, 48, 48, Color(128,128,255,col2), 0 )
end