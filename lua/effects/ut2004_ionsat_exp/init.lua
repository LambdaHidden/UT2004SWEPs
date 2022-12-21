EFFECT.FlareMat = Material("ut2004/epicparticles/flares/BurnFlare1")
EFFECT.GlowMat = Material("particle/particle_glow_04")
EFFECT.IonSphereMat = Material("ut2004/epicparticles/smoke/smokepuff")
EFFECT.IonSphere2Mat = Material("ut2004/epicparticles/smoke/smokepuff2")

function EFFECT:Init(data)
	self:SetModel("models/ut2004/particlemeshes/complex/ionsphere.mdl")
	self.Pos = data:GetOrigin()
	self:SetRenderBounds(Vector(-2048, -2048, -1024), Vector(2048, 2048, 1024))
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	self.Color = Color(255,255,255,255)
	self.Color1 = Color(255,192,255,255)
	self.Color2 = Color(0,0,0,255)
	self.RingAlpha = 1024
	self.GlowAlpha = 800
	self.SmokeAlpha = 800
	
	self.DefMatrix = Matrix()
	self.RotMatrix = Matrix({{2, 0, 0, 0.5}, {0, 2, 0, 0}, {0, 0, 2, 0}, {0, 0, 0, 2}})
	
	self.InnerClock = 0.0
end

function EFFECT:Think()
	self.InnerClock = self.InnerClock + FrameTime()
	
	return self.InnerClock < 2.0
end

function EFFECT:Render()
	if self.InnerClock < 0.75 then
		local flaresize = math.sin(self.InnerClock*4) * 2048
		render.SetMaterial(self.FlareMat)
		render.DrawSprite(self.Pos, flaresize, flaresize, self.Color1) -- Initial flare
	end
	if self.InnerClock > 0.5 then
		self:SetColor(color_white)
		--self:SetRenderAngles(angle_zero)
		local starttime = self.InnerClock - 0.5
		
		
		self.GlowAlpha = (1.5 - self.InnerClock) * 800
		self.Color1.a = math.Clamp(self.GlowAlpha, 1, 255)
		
		render.SetMaterial(self.GlowMat) -- Background glow
		render.DrawSprite(self.Pos, starttime*1500, starttime*1500, self.Color1)
		
		
		self.IonSphereMat:SetMatrix( "$basetexturetransform", self.RotMatrix )
		local size1 = (self.InnerClock - 0.75) * 420 -- Smoke puff
		render.SetMaterial(self.IonSphereMat)
		render.DrawSphere(self.Pos, size1, 16, 16, self.Color1)
		
		self.IonSphereMat:SetMatrix( "$basetexturetransform", self.DefMatrix )
		local size1a = (self.InnerClock - 0.75) * 440
		render.SetMaterial(self.IonSphereMat)
		render.DrawSphere(self.Pos, size1a, 16, 16, self.Color1)
		
		
		self.SmokeAlpha = (1.75 - self.InnerClock) * 800 --math.sin(self.InnerClock*2.5 - 1) * 800
		self.Color2.a = math.Clamp(self.SmokeAlpha, 1, 255)
		
		self.IonSphere2Mat:SetMatrix( "$basetexturetransform", self.RotMatrix )
		local size2 = (self.InnerClock - 0.75) * 380 -- Black smoke puff
		render.SetMaterial(self.IonSphere2Mat)
		render.DrawSphere(self.Pos, size2, 16, 16, self.Color2)
		
		self.IonSphere2Mat:SetMatrix( "$basetexturetransform", self.DefMatrix )
		local size2a = (self.InnerClock - 0.75) * 400
		render.SetMaterial(self.IonSphere2Mat)
		render.DrawSphere(self.Pos, size2a, 16, 16, self.Color2)
		
		
		local matrix = Matrix() -- Big rings
		self.RingAlpha = (2 - self.InnerClock) * 512
		self.Color.a = math.Clamp(self.RingAlpha, 1, 255)
		
		self:SetColor(self.Color)
		local size3 = math.Clamp(starttime*6-2, 0, 2048)
		matrix:Scale(Vector(size3, size3, 3))
		self:EnableMatrix("RenderMultiply", matrix )
		self:DrawModel()
		matrix = Matrix()
		local size4 = math.Clamp(starttime*10-1, 0, 2048)
		matrix:Scale(Vector(size4, size4, 2.5))
		self:EnableMatrix("RenderMultiply", matrix )
		self:DrawModel()
		
	end
end