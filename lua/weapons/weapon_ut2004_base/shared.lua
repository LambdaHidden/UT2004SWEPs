
if SERVER then

	AddCSLuaFile()
	CreateConVar("ut2k4_restrictsuperweps", 0, FCVAR_NOTIFY, "Restrict Superweapons")
	CreateConVar("ut2k4_unlimitedammo", 0, FCVAR_NOTIFY, "Unlimited ammo for everyone")
	CreateConVar("ut2k4_weaponsstay", 1, bit.bor(FCVAR_NOTIFY, FCVAR_ARCHIVE), "Weapons dont vanish when grabbed. Ammo only given the first time.")
	CreateConVar("ut2k4_shieldgun_impulse", 9, bit.bor(FCVAR_NOTIFY, FCVAR_ARCHIVE), "Force multiplier for Shield Gun boosted jumps. Default is 9.")
	
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if CLIENT then

	--include("cl_ammodisp.lua")

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFlip		= false
	SWEP.SwayScale 			= .1
	SWEP.BobScale			= 0
	SWEP.UTBobScale			= 1
	
	CreateClientConVar("ut2k4_bobscale", 1)
	CreateClientConVar("ut2k4_lighting", 1)
	CreateClientConVar("ut2k4_shieldsound", 1)
end

SWEP.Author				= "Upset & Hidden"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""
SWEP.Category			= "Unreal Tournament 2004"
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
	self:NetworkVar("Float", 1, "HolsterDelay")
	self:NetworkVar("Float", 2, "AttackHolsterDelay")
	self:NetworkVar("Bool", 0, "Holstering")
	self:NetworkVar("Bool", 1, "Attack")
	self:NetworkVar("Bool", 2, "SecAttack")
	self:NetworkVar("Entity", 0, "NewWeapon")
	
	self:NetworkVar("Float", 3, "AttackDelay")
	self:NetworkVar("Float", 4, "SecAttackDelay")
	
	--self:NetworkVar("Bool", 3, "Zoom")
	--self:NetworkVar("Float", 5, "ZoomTime")
	--self:NetworkVar("Float", 6, "ZoomStart")
	
	--self:NetworkVar("Float", 5, "ShotAmount")
	self:SpecialDT()
end

function SWEP:SpecialDT()
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	--self:SetHolstering(false)
	self:SpecialInit()
end

function SWEP:SpecialInit()
end

function SWEP:OnRestore()
	self.cantholster = nil
end

function SWEP:Deploy()
	local preshottime = CurTime() + self.DelayBeforeShot
	if self:GetNextPrimaryFire() < preshottime then
		self:SetNextPrimaryFire(preshottime)
		self:SetNextSecondaryFire(preshottime)
	end
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:PlayDeploySound()
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	self:SpecialDeploy()
	return true
end

function SWEP:SpecialDeploy()
end

function SWEP:PlayDeploySound()
	local owner = self:GetOwner()
	if owner && owner:IsValid() && owner:IsPlayer() && owner:Alive() then
		self:EmitSound(self.DeploySound)
	end
end

function SWEP:DelayedHolster(wep)
	if IsValid(wep) and !self:GetHolstering() then
		self:SetNewWeapon(wep)
		if self:GetHolsterDelay() <= CurTime() then
			self:SetIdleDelay(0)
			self:SetNextPrimaryFire(CurTime() + .5)
			self:SetNextSecondaryFire(CurTime() + .5)
			self:SendWeaponAnim(ACT_VM_HOLSTER)
			self:SpecialHolster()
			local delay = self.HolsterTime or self:SequenceDuration()
			self:SetHolsterDelay(CurTime() + delay)
		end
	end
end

function SWEP:SpecialHolster()
end

function SWEP:CanHolster()
	return !self:GetAttack() and !self:GetSecAttack() and (!self.cantholster or self.cantholster <= CurTime())
end

function SWEP:Holster(wep)
	if self == wep then
		return
	end
	
	if self:GetHolstering() or !IsValid(wep) then
		if !self.NoOnRemoveCallOnHolster then
			self:OnRemove()
		end
		if game.SinglePlayer() then
			self:CallOnClient("ResetBonePositions")
		else
			if CLIENT then
				self:ResetBonePositions()
			end
		end
		self:SetHolsterDelay(0)
		self:SetHolstering(false)
		self:SetNewWeapon(NULL)
		return true
	end
	
	if self.bInAttack or self.IsGuidingNuke then return end

	if !self:CanHolster() then
		if IsValid(wep) then
			self:SetHolsterDelay(0)
			self:SetNewWeapon(wep)
			local t = self.cantholster or CurTime()
			self:SetAttackHolsterDelay(t)
		end
		return false
	end
	
	--if self:GetClass() == "weapon_ut99_enforcer" and wep:GetClass() == "weapon_ut99_dualenforcers" then return true end
	
	self:DelayedHolster(wep)
	
	return false
end

function SWEP:OnRemove()
end

function SWEP:OnDrop()
	self:OnRemove()
end

function SWEP:WeaponSound(snd, chan)
	if game.SinglePlayer() and SERVER or !game.SinglePlayer() then
		
		self:EmitSound(snd, 100, 100, 1, chan or CHAN_AUTO)
	end
	self:DisableHolster()
end

function SWEP:DisableHolster(time)
	time = time or -.1
	self.cantholster = self:GetNextPrimaryFire() +time
end

function SWEP:UDSound()
	if self:GetOwner().UT2K4UDamage then
		if game.SinglePlayer() and SERVER or !game.SinglePlayer() then
			self:EmitSound("Weapon_UT2004.AmpFire", 100, 100, 1, CHAN_AUTO)
		end
	end
end

function SWEP:Reload()
end

function SWEP:Think()
	self:SpecialThink()
	if game.SinglePlayer() and CLIENT then return end

	local holsterDelay = self:GetHolsterDelay()
	if holsterDelay > 0 and holsterDelay <= CurTime() then
		if IsValid(self:GetOwner()) and self:GetOwner():Alive() and self:GetOwner():GetActiveWeapon() == self and self:CanHolster() then
			local wep = self:GetNewWeapon()
			if IsValid(wep) then
				self:SetHolstering(true)
				if game.SinglePlayer() then
					self:GetOwner():SelectWeapon(wep:GetClass())
				elseif CLIENT and IsFirstTimePredicted() then
					input.SelectWeapon(wep)
				end
			end
		else
			self:SetHolsterDelay(0)
		end
	end
	
	local attHolsterDelay = self:GetAttackHolsterDelay()
	if attHolsterDelay > 0 and attHolsterDelay <= CurTime() then
		self:SetAttackHolsterDelay(0)
		local wep = self:GetNewWeapon()
		if IsValid(wep) then
			self:Holster(wep)
		end
	end
	
	local idle = self:GetIdleDelay()
	if idle > 0 and CurTime() > idle then
		self:SetIdleDelay(0)
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:SpecialThink()
end

function SWEP:ShootBullet(dmg, recoil, numbul, cone, tracechance, tracename)
	local own = self:GetOwner()
	
	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	tracechance = tracechance or 3
	tracename = tracename or nil

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= own:GetShootPos()
	bullet.Dir 		= own:GetAimVector()
	bullet.Spread 	= Vector(cone, cone, 0)
	bullet.Tracer	= tracechance
	bullet.TracerName = tracename
	bullet.Force	= 10
	bullet.Damage	= dmg
	
	own:FireBullets(bullet)
	own:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:CanPrimaryAttack()
	if !self:GetOwner():IsNPC() then
		if self:GetOwner():GetAmmoCount(self.Primary.Ammo) == 0 then
			self:SetNextPrimaryFire(CurTime() + 0.2)
			self:SetNextSecondaryFire(CurTime() + 0.2)
			return false	 
		end
	end
	return true
end

function SWEP:TakeAmmo(count)
	if !cvars.Bool("ut2k4_unlimitedammo") and !self:GetOwner():IsNPC() then
		self:TakePrimaryAmmo(count)
	end
end
function SWEP:TakeAmmo2(count)
	if !cvars.Bool("ut2k4_unlimitedammo") and !self:GetOwner():IsNPC() then
		self:TakeSecondaryAmmo(count)
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
	local pos = self:GetOwner():GetShootPos()
	local ang = self:GetOwner():EyeAngles()
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
	fx:SetOrigin(self:GetOwner():GetShootPos() +self:GetOwner():GetForward() *self.LightForward +self:GetOwner():GetRight() *self.LightRight +self:GetOwner():GetUp() *self.LightUp)
	fx:SetAttachment(1)
	util.Effect(self.MuzzleName, fx)
	--util.Effect("ut99_mlight_minigun", fx)
end

if SERVER then return end

local udamagemat2004 = Material("ut2004/xgameshaders/playershaders/WeaponUDamageShader")

function SWEP:WorldModelMaterial()	
	self:DrawModel()
	if self:GetOwner().UT2K4UDamage then
		render.MaterialOverride(udamagemat2004)
		self:DrawModel()
		render.MaterialOverride(0)
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
	if !IsValid(self) then return end
	if !IsValid(self:GetOwner()) then return end
	local reg = debug.getregistry()
	local GetVelocity = reg.Entity.GetVelocity
	local Length = reg.Vector.Length2D
	local vel = Length(GetVelocity(self:GetOwner()))
	
	--local vel = self:GetOwner():GetVelocity():Length2D()
	
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
	if self:GetOwner():IsOnGround() then
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
	if !self:IsValid() then return end
	
	local owner = self:GetOwner()
	if !owner:IsValid() then return end
	
	local vm = owner:GetViewModel()
	if !vm:IsValid() then return end
	
	--vm:SetupBones()
	for i=0, (vm:GetBoneCount() or 0) - 1 do
		vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
		vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
		vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
	end
end
