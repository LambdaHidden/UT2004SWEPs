--local exists = file.Exists("materials/ut2004/xgameshaders/flak_flash.vmt", "GAME")
EFFECT.mat = Material("ut2004/xgameshaders/weaponshaders/flakflashfinal")

function EFFECT:Init(data)	
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.time = CurTime()+1
	self.Refract = 0
	self.Size = 48
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	--self.Size = 64 * self.Refract^(0.3)
	if self.Refract >= .05 then return false end	
	return true
end

function EFFECT:Render()
	local Muzzle = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	if !self.WeaponEnt or !IsValid(self.WeaponEnt) or !Muzzle then return end
	render.SetMaterial( self.mat )
	--if exists then
		self.mat:SetInt("$frame", math.Clamp(math.floor(20-(self.time-CurTime())*20),0,9))
	--end
	render.DrawSprite(Muzzle, self.Size, self.Size, Color(255,255,255,150))
	self:SetRenderBoundsWS(Muzzle, self.Position)
end

/*
function EFFECT:Init(data)	
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Refract = 0
	self.Size = 0
end

EFFECT.mat = Material("sprites/ut99/muzzleflash2")

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	self.Size = 64 * self.Refract^(0.3)
	if self.Refract >= .05 then return false end	
	return true
end

function EFFECT:Render()
	local Muzzle = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
	if !self.WeaponEnt or !IsValid(self.WeaponEnt) or !Muzzle then return end
	render.SetMaterial(self.mat)
	render.DrawSprite(Muzzle, self.Size, self.Size, Color(255,255,255,150))
	self:SetRenderBoundsWS(Muzzle, self.Position)
end
*/