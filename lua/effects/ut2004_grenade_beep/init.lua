EFFECT.Mat1 = "ut2004/vmweaponstx/PlayerWeaponsGroup/grenade_outline.vmt"
EFFECT.Mat2 = "particle/particle_ring_wave_additive"
EFFECT.Mat3 = "ut2004/effects/grenade_ring.vmt"
function EFFECT:Init(data)
	self.Ent = data:GetEntity()
	
	self:SetRenderBounds( Vector(-8, -8, -8), Vector(8, 8, 8))
	/*
	if cvars.Bool("ut2k4_lighting") then
		local dynlight = DynamicLight(0)
		dynlight.Pos = self.Ent:GetPos()
		dynlight.Size = 16
		dynlight.Decay = 64
		dynlight.R = 255
		dynlight.G = 128
		dynlight.B = 128
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+2
	end
	*/
	self:SetModel("models/ut2004/vmweaponssm/playerweaponsgroup/vmgrenade.mdl")
	self:SetMaterial(self.Mat2)

	self.Time = 0
	self.Size = 0.5
	self.Size2 = 1
	self.Color = HSVToColor(data:GetColor() or color_red, 1, 1)
	--PrintTable(self.Color)
	self.ColorActual = HSVToColor(data:GetColor() or color_red, 1, 1)
end

function EFFECT:Think()
	self.Time = self.Time + FrameTime()
	self.Size = math.max(0.5 + self.Time, 0.5)
	self.Size2 = math.max(1 + self.Time * 64, 1)
	
	return IsValid(self) and self.Time < 1 and IsValid(self.Ent)
end

function EFFECT:Render()
	if !IsValid(self) or !IsValid(self.Ent) then return end
	--local col = 255 - self.Time * 255
	--col = math.Clamp(col, 0, 255)
	
	self.ColorActual.r = self.Color.r * (1 - self.Time)
	self.ColorActual.g = self.Color.g * (1 - self.Time)
	self.ColorActual.b = self.Color.b * (1 - self.Time)
	
	self:SetRenderAngles(self.Ent:GetAngles())
	self:SetRenderOrigin( self.Ent:GetPos() )
	self:SetModelScale(self.Size)
	render.MaterialOverride( Material(self.Mat1) )
	self:SetColor(self.ColorActual) --Color(col*2, col*2, col*2, 255)
	self:DrawModel()
	render.MaterialOverride( nil )
	
	render.SetMaterial( Material(self.Mat2) )
	render.DrawSprite(self.Ent:GetPos(), self.Size2-10, self.Size2-10, self.ColorActual) --Color(col,col*0.5,col*0.5,255)
	render.SetMaterial( Material(self.Mat3) )
	render.DrawSprite(self.Ent:GetPos(), self.Size2, self.Size2, self.ColorActual)
end