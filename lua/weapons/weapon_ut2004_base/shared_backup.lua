
if SERVER then

	AddCSLuaFile()
	CreateConVar("ut2k4_restrictredeemer", 0, FVAR_NONE, "Restrict Redeemer")
	CreateConVar("ut2k4_unlimitedammo", 0, FCVAR_NOTIFY, "Unlimited ammo for everyone")
	CreateConVar("ut2k4_weaponsstay", 1, FCVAR_NOTIFY, "Weapons can always be picked up")
	
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if CLIENT then

	include("cl_ammodisp.lua")

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFlip		= false
	SWEP.SwayScale 			= .1
	SWEP.BobScale			= 0
	SWEP.UTBobScale			= 1
	
	CreateClientConVar("ut2k4_bobscale", 1)
	CreateClientConVar("ut2k4_lighting", 1)
end

SWEP.Author				= "Upset & Hidden"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""
SWEP.Category			= "Unreal Tournament"
SWEP.Spawnable			= false

SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.DelayBeforeShot		= .5

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "IdleDelay")
	self:NetworkVar("Bool", 0, "Attack")
	self:NetworkVar("Bool", 1, "SecAttack")
	
	self:NetworkVar("Float", 1, "AttackDelay")
	self:NetworkVar("Float", 2, "SecAttackDelay")
	
	self:NetworkVar("Bool", 2, "Zoom")
	self:NetworkVar("Float", 3, "ZoomTime")
	self:NetworkVar("Float", 4, "ZoomStart")
	
	self:NetworkVar("Bool", 3, "Holstering")
	
	self:NetworkVar("Float", 5, "ShotAmount")
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:SetHolstering(false)
end

function SWEP:OnRestore()
	self.cantholster = nil
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() +self.DelayBeforeShot)
	self:SetNextSecondaryFire(CurTime() +self.DelayBeforeShot)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:PlayDeploySound()
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	return true
end

function SWEP:PlayDeploySound()
	local owner = self:GetOwner()
	if (owner && owner:IsValid() && owner:IsPlayer() && owner:Alive()) then
		self:EmitSound(self.DeploySound)
	end
end

function SWEP:Holster(wep)
	if self.cantholster and self.cantholster > CurTime() then return false end
	
	if self == wep then
		return
	end
	
	if !IsValid(wep) then
		if game.SinglePlayer() then
			self:CallOnClient("OnRemove")
		end
		self:OnRemove()
		return true
	end
	
	if self.bInAttack or self.IsGuidingNuke then return end

	--if self.cantholster and self.cantholster > CurTime() then
		if IsValid(wep) and !self:GetHolstering() then
			self.NewWeapon = wep:GetClass()
			self:SendWeaponAnim(ACT_VM_HOLSTER)
			self:SetHolstering(true)
			self.cantholster = CurTime() + self:SequenceDuration() - 0.05
			timer.Simple(self:SequenceDuration(), function()
				if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
					if SERVER then self.Owner:SelectWeapon(self.NewWeapon) end
				end
			end)
			return false
		end
	
	self:SetHolstering(false)
	self:SetIdleDelay(0)
	--end
	if game.SinglePlayer() then
		self:CallOnClient("OnRemove")
	end
	self:OnRemove()
	return true
end

function SWEP:WeaponSound(snd)
	if game.SinglePlayer() and SERVER or !game.SinglePlayer() then
		self:EmitSound(snd, 100, 100, 1, CHAN_AUTO)
	end
	self:DisableHolster()
end

function SWEP:DisableHolster(time)
	time = time or -.1
	self.cantholster = self:GetNextPrimaryFire() +time
end

function SWEP:UDSound()
	if self.Owner.UT2K4UDamage then
		if game.SinglePlayer() and SERVER or !game.SinglePlayer() then
			self:EmitSound("Weapon_UT2004.AmpFire", 100, 100, 1, CHAN_AUTO)
		end
	end
end

function SWEP:Reload()
end

function SWEP:Think()
	self:SpecialThink()
	
	local idle = self:GetIdleDelay()
	if idle > 0 and CurTime() > idle then
		self:SetIdleDelay(0)
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:SpecialThink()
end

function SWEP:ShootBullet(dmg, recoil, numbul, cone, tracechance, tracename)
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	tracechance = tracechance or 3
	tracename = tracename or nil

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector(cone, cone, 0)
	bullet.Tracer	= tracechance
	bullet.TracerName = tracename
	bullet.Force	= 10
	bullet.Damage	= dmg
	
	self.Owner:FireBullets(bullet)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:CanPrimaryAttack()
	if !self.Owner:IsNPC() then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) == 0 then
			self:SetNextPrimaryFire(CurTime() + 0.2)
			self:SetNextSecondaryFire(CurTime() + 0.2)
			return false	 
		end
	end
	return true
end

function SWEP:TakeAmmo()
	if !cvars.Bool("ut2k4_unlimitedammo") and !self.Owner:IsNPC() then
		self:TakePrimaryAmmo(1)
	end
end
function SWEP:TakeAmmo2()
	if !cvars.Bool("ut2k4_unlimitedammo") and !self.Owner:IsNPC() then
		self:TakeSecondaryAmmo(1)
	end
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	surface.SetDrawColor(255, 255, 255, 245)
	surface.SetTexture(self.WepSelectIcon)
	
	--y = y + 24
	--x = x + 34
	--wide = wide - 64
	--tall = tall - 64
	
	surface.DrawTexturedRect(x, y+24, wide, tall-64)

end

function SWEP:Muzzleflash()
	if !IsFirstTimePredicted() then return end
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:EyeAngles()
	pos = pos +ang:Forward() *self.LightForward +ang:Right() *self.LightRight +ang:Up() *self.LightUp
	
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(pos)
	fx:SetAttachment(1)
	fx:SetStart(self.LightColor)
	util.Effect(self.MuzzleName, fx)
	if !cvars.Bool("ut2k4_lighting") then return end
	util.Effect("ut2004_mflash_light", fx)
end

function SWEP:MuzzleflashSprite()
	if !IsFirstTimePredicted() then return end
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self.Owner:GetShootPos() +self.Owner:GetForward() *self.LightForward +self.Owner:GetRight() *self.LightRight +self.Owner:GetUp() *self.LightUp)
	fx:SetAttachment(1)
	util.Effect(self.MuzzleName, fx)
	--util.Effect("ut99_mlight_minigun", fx)
end

if SERVER then return end

local udamagemat2004 = Material("models/ushader")

function SWEP:WorldModelMaterial()	
	if self.Owner.UT2K4UDamage then
		render.MaterialOverride(udamagemat2004)
		self:DrawModel()
		render.MaterialOverride(0)
	else
		self:DrawModel()
	end
end

function SWEP:DrawWorldModel()
	self:WorldModelMaterial()
end

/*local recoilpos = 0
function SWEP:CalcView(ply, pos, ang, fov)
	recoilpos = ply:GetViewPunchAngles()[1] * 30
	recoilpos = math.max(recoilpos, -5)
	pos[3] = pos[3] + recoilpos
	return pos, ang
end*/

local BobTime = 0
local BobTimeLast = RealTime()

local t = 1

function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	local reg = debug.getregistry()
	local GetVelocity = reg.Entity.GetVelocity
	local Length = reg.Vector.Length2D
	local vel = Length(GetVelocity(self.Owner))
	
	local bob
	local RT = RealTime()
	if game.SinglePlayer() then RT = CurTime() end
	
	local cl_bobmodel_side = .15
	local cl_bobmodel_up = .055
	local cl_bobmodel_speed = 8.7
	local cl_viewmodel_scale = self.UTBobScale * math.Clamp(cvars.Number("ut2k4_bobscale"), 0, 5)

	local xyspeed = math.Clamp(vel, 0, 320)
	
	BobTime = BobTime + (RT - BobTimeLast) * (xyspeed / 320)
	BobTimeLast = RT

	local s = BobTime * cl_bobmodel_speed
	if self.Owner:IsOnGround() then
		t = math.Approach(t, 1, FrameTime() * 6)
	else
		t = math.Approach(t, 0, FrameTime() * 3)
	end

	local bspeed = xyspeed * 0.01
	bob = bspeed * cl_bobmodel_side * cl_viewmodel_scale * math.sin (10.55 + s) * t
	local modelindex = vm:ViewModelIndex()
	if modelindex == 0 then
		pos = pos + bob * ang:Right()
	else
		pos = pos - bob * ang:Right()
	end	
	bob = bspeed * cl_bobmodel_up * cl_viewmodel_scale * math.cos (0.45 + s *2) * t
	pos[3] = pos[3] - bob
	
	//pos[3] = pos[3] + recoilpos
	
	return pos, ang
end

function SWEP:ResetBonePositions()
	local vm = self.Owner:GetViewModel()
	if (!vm:GetBoneCount()) then return end
	--vm:SetupBones()
	for i=0, vm:GetBoneCount() do
		vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
		vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
		vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
	end
end