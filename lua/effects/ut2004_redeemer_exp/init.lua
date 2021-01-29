EFFECT.Mat1 = Material("ut2004/effects/FlameGradient.vmt")
function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	/*
	if cvars.Bool("quake4_firelight") then
		local dynlight = DynamicLight(0)
		dynlight.Pos = self.Pos
		dynlight.Size = 1024
		dynlight.Decay = 2048
		dynlight.R = 115
		dynlight.G = 90
		dynlight.B = 130
		dynlight.Brightness = 5
		dynlight.DieTime = CurTime()+1
	end
	*/
	self:SetModel("models/XQM/Rails/gumball_1.mdl") 
	self:SetMaterial(self.Mat1)

	self.Time = 0
	self.Size = 0
	self.Size2 = 0
end

function EFFECT:Think()
	self.Time = self.Time + FrameTime()
	self.Size = math.max(self.Time * 48, 0)
	self.Size2 = math.max(self.Time * 72, 0)
	
	return self.Time < 1
end

function EFFECT:Render()
	local col = 255 - self.Time * 200
	col = math.Clamp(col, 0, 255)
	
	--self:SetModelScale(self.Size)
	--self:SetColor(Color(col,col,col))
	--render.MaterialOverride(self.Mat1)
	--render.SetMaterial( self.Mat1 )
	--self:DrawModel()
	render.SetMaterial(self.Mat1)
	self:SetRenderAngles( Angle(0,0,0) )
	render.DrawSphere( self:GetPos(), self.Size*16, 16, 8, Color( 255,255,255,col ) )
	self:SetRenderAngles( Angle(0,90,0) )
	render.DrawSphere( self:GetPos(), self.Size2*16, 16, 8, Color( 255,255,255,col ) )
end