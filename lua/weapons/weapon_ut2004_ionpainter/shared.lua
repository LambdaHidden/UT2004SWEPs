

if SERVER then

	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

	SWEP.PrintName			= "Ion Painter"
	SWEP.Author				= "Hidden"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 1
	SWEP.UTSlot				= 10
	SWEP.Weight				= 11
	SWEP.ViewModelFOV		= 50
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/ionpainter" )
	SWEP.UTBobScale			= .6
	language.Add( "ammo_tgtpainter", "Painter battery" )
	--killicon.Add( "weapon_ut99_rifle", "vgui/ut99/rifle", Color( 255, 80, 0, 255 ) )
	
	local RReticle = surface.GetTextureID("ut2004/xweapons_rc/icons/SniperFocus")
	local RArrows = surface.GetTextureID("ut2004/xweapons_rc/icons/SniperArrows")
	local RBorder = surface.GetTextureID("ut2004/xweapons_rc/icons/SniperBorder")
	local RInterlace1 = surface.GetTextureID("ut2004/xgameshaders/zoomfx/fulloverlay")
	local RScanLine = surface.GetTextureID("ut2004/xgameshaders/zoomfx/zoomfb")
	
	function SWEP:DrawHUD()
		local x, y
		x, y = ScrW() *0.5, ScrH() *0.5
		
		if self:GetZoom() then
			surface.SetDrawColor(255, 255, 255, 255)
			
			surface.SetTexture(RInterlace1)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			
			surface.SetTexture(RReticle)
			surface.DrawTexturedRect(x-x/2+64, y-y/2-46, x-128, y+92)
			
			surface.SetTexture(RArrows)
			surface.DrawTexturedRect(x - 64 , y - 64 , 128, 128)
			
			surface.SetTexture(RScanLine)
			surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, 4, 4 )
			
			surface.SetTexture(RBorder)
			surface.SetDrawColor( 255, 255, 255, 192 )
			surface.DrawTexturedRectUV( 0, 0, 128, 128, 0, 0, 1, 1 ) --Vignette top left
			surface.DrawTexturedRectUV( ScrW()-128, 0, 128, 128, 1, 0, 0, 1 ) --Vignette top right
			surface.DrawTexturedRectUV( 0, ScrH()-128, 128, 128, 0, 1, 1, 0 ) --Vignette bottom left
			surface.DrawTexturedRectUV( ScrW()-128, ScrH()-128, 128, 128, 1, 1, 0, 0 ) --Vignette bottom right
			
			local charge = self.LaserBrightness2 * 255
			local charge1 = self:GetPaintState() > 0 and self.LaserBrightness2 * 450 or 0
			
			surface.SetDrawColor(charge, 0, charge, 255)
			surface.DrawRect(ScrW()-100, y+230 - charge1, 40 , charge1)
		end
	end
	
end

function SWEP:SpecialDT()
	self:NetworkVar("Bool", 3, "Zoom")
	self:NetworkVar("Float", 5, "ZoomTime")
	self:NetworkVar("Float", 6, "ZoomStart")
	self:NetworkVar("Int", 0, "PaintState")
	--self:NetworkVar("Vector", 0, "MarkLocation")
end

function SWEP:SpecialInit()
	self.Sattelites = ents.FindByClass("ut2004_ion_sat")
	if table.IsEmpty(self.Sattelites) then
		self.UsingSats = false
		return
	end
	self.UsingSats = true
end

function SWEP:OnRemove()
	self:SetZoom(false)
	self:SetZoomStart(0)
end


function SWEP:CanBomb(pos)
	local trdata = {
		start = pos,
		endpos = pos + Vector(0,0,16384),
		mask = MASK_SOLID
	}
	
	if !self.UsingSats then
		local tr = util.TraceLine(trdata)
		return tr.HitSky or !tr.Hit
	else
		for k, v in ipairs(self.Sattelites) do
			if !IsValid(v) then 
				self:SpecialInit() 
				return false
			end
			trdata.endpos = v:GetPos()
			local tr = util.TraceLine(trdata)
			if tr.HitSky or tr.Entity == v then
				return true
			end
		end
	end
end

local beamstarts = {
	Vector(-512, 0, 3000),
	Vector(0, 0, 3200),
	Vector(512, 0, 3000)
}

function SWEP:SpawnBomber(MarkLocation)
	local own = self:GetOwner()
	
	local eff = EffectData()
	eff:SetOrigin(MarkLocation)
	
	local Sats = self.UsingSats and self.Sattelites or beamstarts
	for k, v in ipairs(Sats) do
		if v == nil then 
			self:SpecialInit() 
			return false
		end
		local pos = !self.UsingSats and MarkLocation + v or v:GetAttachment(1).Pos
		
		eff:SetStart(pos)
		util.Effect("ut2004_ionsat_beam", eff)
	end
	
	self:EmitSound("ut2004/weaponsounds/tagrifle/IonCannonBlast.wav", 1)
	EmitSound("ut2004/weaponsounds/tagrifle/IonCannonBlast.wav", MarkLocation, self:EntIndex(), CHAN_AUTO, 1, 256)
	
	timer.Simple(0.5, function()
		if SERVER then
			local killer = ents.Create( "ut2004_redeemer_exp" )
			killer:SetOwner(own)
			killer:SetPos(MarkLocation)
			killer:Spawn()
			killer:Activate()
			
			killer:EmitSound("ut2004/weaponsounds/misc/redeemer_explosionsound.wav", 500)
		end
		util.Effect("ut2004_ionsat_exp", eff)
	end)
	return true
end

function SWEP:PaintTarget()
	local own = self:GetOwner()
	local eyetr = util.QuickTrace( own:GetShootPos(), own:GetAimVector()*10000, own ) --9165
	local ct = CurTime()
	
	local PaintDuration = 1.0
	
	self:DisableHolster(0.2)
	if self:GetPaintState() == 0 then
		self:SetPaintState(1)
		self:EmitSound(self.Primary.Sound, 40)
		self:SetNextPrimaryFire(ct + 0.25)
		self.MarkTime = ct
	elseif self:GetPaintState() == 1 then
		if !self.MarkLocation then
			if !eyetr.HitWorld then return end
			self.MarkLocation = self:CanBomb(eyetr.HitPos) and eyetr.HitPos or nil
			self.MarkTime = ct
		else
			if self.MarkLocation:DistToSqr(eyetr.HitPos) < 930 then
				if ct - self.MarkTime > 0.3 then
					self:SetPaintState(2)
					self:WeaponSound(self.Secondary.Sound)
				end
			else
				self.MarkLocation = nil
			end
		end
	elseif self:GetPaintState() == 2 then
		if self.MarkLocation:DistToSqr(eyetr.HitPos) < 930 then
			if ct - self.MarkTime > PaintDuration and self:SpawnBomber(self.MarkLocation) then
				self:SetPaintState(0)
				self.MarkLocation = nil
				self.MarkTime = 0
				self:StopSound(self.Primary.Sound)
				self:SetNextPrimaryFire(CurTime() + 3)
				self:TakeAmmo(1)
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				self:SetIdleDelay(ct + self:SequenceDuration())
			end
		else
			self.MarkLocation = nil
			self:SetPaintState(1)
		end
	end
end

function SWEP:Restricted()
	self:SetNextPrimaryFire(CurTime() + 2)
	self:SetNextSecondaryFire(CurTime() + 2)
	if !self:GetOwner():IsNPC() then self:GetOwner():PrintMessage(HUD_PRINTCENTER, "Superweapons are restricted!") end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	if cvars.Bool("ut2k4_restrictsuperweps") then
		self:Restricted()
		return
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	self:PaintTarget()
end

function SWEP:SecondaryAttack()
	if !self:GetZoom() then
		self:SetZoom(true)
		self:SetZoomTime(1)
		if game.SinglePlayer() and SERVER or CLIENT then
			self:GetOwner():DrawViewModel(false)
		end
		self:SetZoomStart(CurTime())
	else 
		self:SetZoom(false)
		self:SetZoomTime(1)
		if game.SinglePlayer() and SERVER or CLIENT then
			self:GetOwner():DrawViewModel(true)
		end
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:SetIdleDelay(CurTime() + self:SequenceDuration())
		self:EmitSound("ut2004/weaponsounds/baseguntech/BZoomOut1.wav", 50)
	end	
end

SWEP.LaserBrightness = 0
SWEP.LaserBrightness2 = 0
SWEP.LaserColor = Color(255, 255, 255, 255)
SWEP.LaserColor2 = Color(255, 255, 255, 255)
function SWEP:SpecialThink()
	local own = self:GetOwner()
	if self:GetZoomStart() > 0 then
		local ct = CurTime()
		self:SetZoomTime(math.max(1-(ct - self:GetZoomStart()), 0))
		self:EmitSound("ut2004/weaponsounds/baseguntech/BZoomIn1.wav", 50)
		if own:KeyReleased(IN_ATTACK2) or ct-.89 >= self:GetZoomStart() then
			self:SetZoomStart(0)
		end
	end
	
	if own:KeyReleased(IN_ATTACK) then
		self:SetPaintState(0)
		self:StopSound(self.Primary.Sound)
		self.MarkLocation = nil
		self.MarkTime = 0
	end
	
	self.LaserBrightness2 = math.Clamp(self.LaserBrightness2 + (self:GetPaintState() == 2 and FrameTime() or 0-FrameTime()*2), 0, 1)
	self.LaserBrightness = math.Clamp(self.LaserBrightness + (self:GetPaintState() > 0 and FrameTime()*4 or 0-FrameTime()*2), 0, 1)
	
	if CLIENT and cvars.Bool("ut2k4_lighting") and self:GetPaintState() > 0 then
		local dlight = DynamicLight(self:EntIndex(), false)
		if (dlight) then
			dlight.pos = own:GetEyeTrace().HitPos
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.brightness = 2
			dlight.Decay = 1280
			dlight.Size = 128
			dlight.DieTime = CurTime() + 0.5
			
			dlight.noworld = false
			dlight.nomodel = true
		end
	end
end

function SWEP:TranslateFOV(fov)
	if self:GetZoom() and self:GetZoomTime() > 0 then
		return fov * self:GetZoomTime()
	else
		return fov
	end
end

function SWEP:AdjustMouseSensitivity()
	if self:GetZoom() then
		return self:GetOwner():GetFOV() / self:GetOwner():GetInfoNum("fov_desired", 90)
	end
end


--local LASER = Material('cable/redlaser')
local LASER = Material('ut2004/xeffectmat/ion/painter_beam')

function SWEP:ViewModelDrawn(vm)
	local own = self:GetOwner()
	if self.LaserBrightness > 0 or self.LaserBrightness2 > 0 then
		local startpos = own:GetShootPos() + own:GetAimVector()*72 + own:GetRight()*21 + own:GetUp()*-11
		-- Draw the laser beam.
		render.SetMaterial( LASER )
		self.LaserColor.a = Lerp( self.LaserBrightness, 0, 255 )
		render.DrawBeam(startpos, own:GetEyeTrace().HitPos, 4, 0, 12.5, self.LaserColor)
		self.LaserColor2.a = Lerp( self.LaserBrightness2, 0, 255 )
		render.DrawBeam(startpos, own:GetEyeTrace().HitPos, 8, 0, 12.5, self.LaserColor2)
	end
end

function SWEP:DrawWorldModel()
	self:DrawModel()
	local own = self:GetOwner()
	if self.LaserBrightness > 0 or self.LaserBrightness2 > 0 then
		local startpos = self:GetAttachment(1).Pos
		-- Draw the laser beam.
		render.SetMaterial( LASER )
		self.LaserColor.a = Lerp( self.LaserBrightness, 0, 255 )
		render.DrawBeam(startpos, own:GetEyeTrace().HitPos, 4, 0, 12.5, self.LaserColor)
		self.LaserColor2.a = Lerp( self.LaserBrightness2, 0, 255 )
		render.DrawBeam(startpos, own:GetEyeTrace().HitPos, 8, 0, 12.5, self.LaserColor2)
	end
end

SWEP.Offset = {
	Pos = {
		Up = 0,
		Right = 0,
		Forward = 0,
	},
	Ang = {
		Up = 0,
		Right = 0,
		Forward = 0,
	}
}

SWEP.HoldType			= "smg"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/painter_1st.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/painter_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/tagrifle/TAGFireA.wav")
SWEP.Primary.Recoil			= .8
SWEP.Primary.Damage			= 60
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= .001
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_tgtpainter"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Sound			= Sound("ut2004/weaponsounds/tagrifle/TAGFireB.wav")

SWEP.DeploySound			= Sound("ut2004/weaponsounds/linkgun/SwitchToLinkGun.wav")

SWEP.MuzzleName				= ""
SWEP.LightForward = 58
SWEP.LightRight = 5
SWEP.LightUp = -8
SWEP.LightColor			= Vector(255, 0, 0)