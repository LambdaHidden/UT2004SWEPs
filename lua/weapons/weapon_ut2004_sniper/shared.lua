

if SERVER then

	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

	SWEP.PrintName			= "Sniper Rifle"
	SWEP.Author				= "Upset & Hidden"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.UTSlot				= 9
	SWEP.Weight				= 7
	SWEP.ViewModelFOV		= 55
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/sniper" )
	SWEP.UTBobScale			= .6
	language.Add( "ammo_rifle", "Rifle rounds" )
	--killicon.Add( "weapon_ut99_rifle", "vgui/ut99/rifle", Color( 255, 80, 0, 255 ) )
	
	local RReticle = surface.GetTextureID("ut2004/effects/CogAssaultZoomedCrosshair")
	
	function SWEP:DrawHUD()
		local x, y
		x, y = ScrW() *0.5, ScrH() *0.5
		
		if self:GetZoom() then
			surface.SetDrawColor(255, 255, 255, 200)
			surface.SetTexture(RReticle)
			
			surface.DrawTexturedRectUV( 0, 0, 256, 256, 0, 0.535, 0.31, 0.225 ) --Vignette top left
			surface.DrawTexturedRectUV( ScrW()-256, 0, 256, 256, 0.31, 0.535, 0, 0.225 ) --Vignette top right
			surface.DrawTexturedRectUV( 0, ScrH()-256, 256, 256, 0, 0.225, 0.31, 0.535 ) --Vignette bottom left
			surface.DrawTexturedRectUV( ScrW()-256, ScrH()-256, 256, 256, 0.31, 0.225, 0, 0.535 ) --Vignette bottom right
			
			surface.DrawTexturedRectUV( 256, 0, ScrW()-512, 256, 0.53, 1, 0.6, 0.69) --Vignette top
			surface.DrawTexturedRectUV( 0, 256, 256, ScrH()-512, 0, 0.58, 0.31, 0.6) --Vignette left
			surface.DrawTexturedRectUV( ScrW()-256, 256, 256, ScrH()-512, 0.31, 0.58, 0, 0.6) --Vignette right
			surface.DrawTexturedRectUV( 256, ScrH()-256, ScrW()-512, 256, 0.53, 0.69, 0.6, 1) --Vignette bottom
			
			
			surface.SetDrawColor(255, 255, 255, 255)
			
			surface.DrawTexturedRectUV( x-256, y-256, 256, 512, 0.32, 0.06, 0.65, 0.68 ) --Left side of the crosshair
			surface.DrawTexturedRectUV( x, y-256, 256, 512, 0.65, 0.68, 0.32, 0.06 ) --Right side of the crosshair
			
			surface.DrawTexturedRectUV( 300, y-256, 196, 196, 0, 0, 0.22, 0.22 ) --Top left corner
			surface.DrawTexturedRectUV( 300, y+64, 196, 196, 0, 0.22, 0.22, 0 ) --Bottom left corner
			
			surface.DrawTexturedRectUV( ScrW() - 512, y-256, 196, 196, 0.22, 0, 0, 0.22 ) --Top right corner
			surface.DrawTexturedRectUV( ScrW() - 512, y+64, 196, 196, 0.22, 0.22, 0, 0 ) --Bottom right corner
		end
	end
	
end

function SWEP:SpecialDT()
	self:NetworkVar("Bool", 3, "Zoom")
	self:NetworkVar("Float", 5, "ZoomTime")
	self:NetworkVar("Float", 6, "ZoomStart")
end

function SWEP:OnRemove()
	self:SetZoom(false)
	self:SetZoomStart(0)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	--self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:Muzzleflash()
	local anim = {ACT_VM_RECOIL1, ACT_VM_RECOIL2, ACT_VM_RECOIL3}
	if !self:GetZoom() then self:SendWeaponAnim(anim[math.random(1,3)]) end
	self:EmitSound(self.Primary.Sound, 100, 100, 1, CHAN_ITEM)
	self:UDSound()
	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	--self:UTRecoil()
	self:DisableHolster()
	self:TakeAmmo()
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
end

function SWEP:SecondaryAttack()
	if !self:GetZoom() then
		self:SetZoom(true)
		self:SetZoomTime(1)
		if game.SinglePlayer() and SERVER or CLIENT then
			self.Owner:DrawViewModel(false)
		end
		self:SetZoomStart(CurTime())
	else 
		self:SetZoom(false)
		self:SetZoomTime(1)
		if game.SinglePlayer() and SERVER or CLIENT then
			self.Owner:DrawViewModel(true)
		end
		self:EmitSound("ut2004/weaponsounds/BZoomOut1.wav", 50)
	end	
end

function SWEP:SpecialThink()
	if self:GetZoomStart() > 0 then
		local ct = CurTime()
		self:SetZoomTime(math.max(1-(ct - self:GetZoomStart()), 0))
		self:EmitSound("ut2004/weaponsounds/BZoomIn1.wav", 50)
		if self.Owner:KeyReleased(IN_ATTACK2) or ct-.89 >= self:GetZoomStart() then
			self:SetZoomStart(0)
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
		return self.Owner:GetFOV() / self.Owner:GetInfoNum("fov_desired", 90)
	end
end

SWEP.Offset = {
	Pos = {
		Up = -1,
		Right = 1.4,
		Forward = 9,
	},
	Ang = {
		Up = 0,
		Right = 10,
		Forward = 0,
	}
}

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_sniper.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_sniper.mdl"

SWEP.Primary.Sound			= Sound("ut2004/newweaponsounds/NewSniperShot.wav")
SWEP.Primary.Recoil			= .8
SWEP.Primary.Damage			= 60
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= .001
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 1.25
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_rifle"

SWEP.Secondary.Automatic	= false

SWEP.DeploySound			= Sound("ut2004/newweaponsounds/NewSniper_load.wav")

SWEP.MuzzleName				= ""
SWEP.LightForward = 58
SWEP.LightRight = 5
SWEP.LightUp = -8
SWEP.LightColor			= Vector(200, 200, 50)