

if SERVER then

	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

	SWEP.PrintName			= "Lightning Gun"
	SWEP.Author				= "Upset & Hidden"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 2
	SWEP.UTSlot				= 9
	SWEP.Weight				= 8
	SWEP.ViewModelFOV		= 55
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/lightning" )
	SWEP.UTBobScale			= .6
	--language.Add( "ammo_rifle", "Rifle rounds" )
	--killicon.Add( "weapon_ut99_rifle", "vgui/ut99/rifle", Color( 255, 80, 0, 255 ) )
	
	local RReticle = surface.GetTextureID("ut2004/xweapons_rc/icons/SniperFocus")
	local RArrows = surface.GetTextureID("ut2004/xweapons_rc/icons/SniperArrows")
	local RInterlace1 = surface.GetTextureID("ut2004/xgameshaders/zoomfx/fulloverlay")
	local RScanLine = surface.GetTextureID("ut2004/xgameshaders/zoomfx/zoomfb")
	
	function SWEP:DrawHUD()
		local x, y
		x, y = ScrW() *0.5, ScrH() *0.5
		
		if self:GetZoom() then
			surface.SetDrawColor(255, 255, 255, 255)
			
			surface.SetTexture(RInterlace1)
			surface.DrawTexturedRect(-x, -y, ScrW()*2, ScrH()*2)
			
			surface.SetTexture(RReticle)
			surface.DrawTexturedRect(128 , -64 , ScrW()-256, ScrH() + 128)
			
			surface.SetTexture(RScanLine)
			surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, 2, 2 )
			
			surface.SetTexture(RArrows)
			surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawTexturedRect(x - 128 , y - 128 , 256, 256)
			
			
			local clamp = math.Clamp(self:GetNextPrimaryFire() - CurTime(), 0 , 1.5)
			local clamp1 = 1.5-clamp
			
			surface.SetDrawColor(128*clamp, 255 * clamp1, 128*clamp, 255)
			surface.DrawRect(ScrW()-100, y+230 - (300*clamp1), 40 , 300 * clamp1)
			--draw.SimpleText("X"..math.Round(-self:GetOwner():GetFOV() / self:GetOwner():GetInfoNum("fov_desired", 90) *8.1 +9.1, 1), "UT99SniperFont", x + 128, y + 180, Color(0,200,0,255), TEXT_ALIGN_LEFT)
			--draw.SimpleText("X"..math.Round((-self:GetZoomTime()+1.115)*8.15, 1), "UT99SniperFont", x + 128, y + 180, Color(0,200,0,255), TEXT_ALIGN_LEFT)
		end
	end
	
end

function SWEP:SpecialDT()
	self:NetworkVar("Bool", 3, "Zoom")
	self:NetworkVar("Float", 5, "ZoomTime")
	self:NetworkVar("Float", 6, "ZoomStart")
end
/*
function SWEP:SpecialDeploy()
	ParticleEffectAttach( "ut2004_lightning_vm", PATTACH_POINT_FOLLOW, self:GetOwner():GetViewModel(), 2 )
end
*/
function SWEP:OnRemove()
	self:SetZoom(false)
	self:SetZoomStart(0)
	self:StopParticles()
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	--self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:Muzzleflash()
	if !self:GetZoom() then self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) end
	
	local own = self:GetOwner()
	
	if SERVER then own:LagCompensation(true) end
	
	local eyetr = own:GetEyeTrace()
	
	self:WeaponSound(self.Primary.Sound, CHAN_ITEM)
	self:WeaponSound("ut2004/weaponsounds/lightninggun/LightningGunChargeUp.wav")
	EmitSound( "ut2004/weaponsounds/BLightningGunImpact.wav", eyetr.HitPos, self:EntIndex() )
	self:UDSound()
	
	util.ParticleTracerEx( "ut2004_lightning", own:GetShootPos(), eyetr.HitPos, false, self:EntIndex(), 1 )
	ParticleEffect( "ut2004_lightning_sparks", eyetr.HitPos, eyetr.HitNormal:Angle() )
	
	self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone, 0 )
	
	if SERVER then own:LagCompensation(false) end
	--self:UTRecoil()
	self:DisableHolster()
	self:TakeAmmo(1)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
end

function SWEP:SecondaryAttack()
	if !self:GetZoom() then
		self:SetZoom(true)
		self:SetZoomTime(1)
		if game.SinglePlayer() and SERVER or CLIENT then
			self:GetOwner():DrawViewModel(false)
		end
		self:GetOwner():GetViewModel():StopParticles()
		self:SetZoomStart(CurTime())
	else 
		self:SetZoom(false)
		self:SetZoomTime(1)
		if game.SinglePlayer() and SERVER or CLIENT then
			self:GetOwner():DrawViewModel(true)
		end
		ParticleEffectAttach( "ut2004_lightning_vm", PATTACH_POINT_FOLLOW, self:GetOwner():GetViewModel(), 2 )
		self:EmitSound("ut2004/weaponsounds/baseguntech/BZoomOut1.wav", 50)
	end	
end

function SWEP:SpecialThink()
	if self:GetZoomStart() > 0 then
		local ct = CurTime()
		self:SetZoomTime(math.max(1-(ct - self:GetZoomStart()), 0))
		self:EmitSound("ut2004/weaponsounds/baseguntech/BZoomIn1.wav", 50)
		if self:GetOwner():KeyReleased(IN_ATTACK2) or ct-.89 >= self:GetZoomStart() then
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
		return self:GetOwner():GetFOV() / self:GetOwner():GetInfoNum("fov_desired", 90)
	end
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/sniper_1st.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/sniper_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/basefiringsounds/BLightningGunFire.wav")
SWEP.Primary.Recoil			= .8
SWEP.Primary.Damage			= 70
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= .001
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 1.5
SWEP.Primary.DefaultClip	= 8
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_rifle"

SWEP.Secondary.Automatic	= false

SWEP.DeploySound			= Sound("ut2004/weaponsounds/lightninggun/SwitchToLightningGun.wav")

SWEP.MuzzleName				= ""
SWEP.LightForward = 50
SWEP.LightRight = 5
SWEP.LightUp = -5
SWEP.LightColor			= Vector(255, 255, 255)