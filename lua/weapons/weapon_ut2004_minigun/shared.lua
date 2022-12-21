

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Minigun"			
	SWEP.Author				= "Upset & Hidden"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 0
	SWEP.UTSlot				= 6
	SWEP.Weight				= 6
	SWEP.ViewModelFOV		= 55
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/minigun" )
	SWEP.UTBobScale			= .8
	--language.Add("ammo_flak_shells_ammo", "Flak Shells")
	--killicon.Add("weapon_ut2004_flak", "vgui/ut2004/flak", Color(255, 80, 0, 255))
	--killicon.Add("ut2004_flak2", "vgui/ut99/flak", Color(255, 80, 0, 255))
	
end

function SWEP:SpecialInit()
	--self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Secondary.Sound)
	--util.PrecacheSound("ut2004/weaponsounds/BExplosion1.wav")	
end

function SWEP:Equip()
	self:GetOwner():GiveAmmo(100, self.Primary.Ammo)
end

function SWEP:SpecialDeploy()
	self:SetAttackDelay(2)
	return true
end

function SWEP:PrimarySoundStart()
	if !self.LoopSound then
		self.LoopSound = CreateSound(self:GetOwner(), self.Primary.Sound)
	end
	if self.LoopSound and !self.LoopSound:IsPlaying() then
		self.LoopSound:Play()
	end
end
function SWEP:SecondarySoundStart()
	if !self.LoopSound1 then
		self.LoopSound1 = CreateSound(self:GetOwner(), self.Secondary.Sound)
	end
	if self.LoopSound1 and !self.LoopSound1:IsPlaying() then
		self.LoopSound1:Play()
	end
end
function SWEP:EmptySoundStart()
	if !self.LoopSound2 then
		self.LoopSound2 = CreateSound(self:GetOwner(), self.Primary.Special)
	end
	if self.LoopSound2 and !self.LoopSound2:IsPlaying() then
		self.LoopSound2:Play()
	end
end


function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if !self:GetAttack() then
		--self:WeaponSound(self.Primary.Special, 75, 100, 1, CHAN_ITEM)
		self:EmptySoundStart()
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:SetAttack(true)
	end

	if self:GetAttackDelay() >= self.BarrelAccelTime then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		if !self:GetSecAttack() then
			self:SendWeaponAnim(ACT_VM_PULLBACK)
			self:PrimarySoundStart()
			self:SetSecAttack(true)
		end
		if SERVER then self:GetOwner():LagCompensation(true) end
		self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, 1, self.Primary.Cone)
		if SERVER then self:GetOwner():LagCompensation(false) end
		--self:Smoke()
		self:TakeAmmo(1)
		self:Muzzleflash()
		--self:SetCannotHolster(CurTime() +.1)
		self:SetIdleDelay(CurTime() + self:SequenceDuration())
	end
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	--if !self:CanSecondaryAttack() then return end
	
	if !self:GetAttack() then
		--self:WeaponSound(self.Primary.Special, 75, 100, 1, CHAN_ITEM)
		self:EmptySoundStart()
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:SetAttack(true)
	end

	if self:GetAttackDelay() >= self.BarrelAccelTime then
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		if !self:GetSecAttack() then
			self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
			self:SecondarySoundStart()
			self:SetSecAttack(true)
		end
		if SERVER then self:GetOwner():LagCompensation(true) end
		self:ShootBullet(self.Secondary.Damage, self.Primary.Recoil, 1, self.Secondary.Cone, 1)
		if SERVER then self:GetOwner():LagCompensation(false) end
		--self:Smoke()
		self:TakeAmmo(1)
		self:Muzzleflash()
		--self:SetCannotHolster(CurTime() +.1)
		self:SetIdleDelay(CurTime() + self:SequenceDuration())
	end
end

function SWEP:SpecialThink()
	if (self:GetOwner():KeyReleased(IN_ATTACK) || self:GetOwner():KeyReleased(IN_ATTACK2)) or self:Ammo1() <= 0 then
		if self:GetAttack() then
			--self:EmitSound(self.Primary.Special1, 75, 100, 1, CHAN_ITEM)
			if self:GetAttackDelay() >= self.BarrelAccelTime then
				self:SendWeaponAnim(ACT_VM_PULLBACK_LOW)
				self:SetIdleDelay(CurTime()+self:SequenceDuration())
			end
		end
		if self.LoopSound then self.LoopSound:Stop() end
		if self.LoopSound1 then self.LoopSound1:Stop() end
		if self.LoopSound2 then self.LoopSound2:Stop() end
		self:SetAttack(nil)
		self:SetSecAttack(nil)
	end
	
	local attdelay = self:GetAttackDelay()
	if (self:GetOwner():KeyDown(IN_ATTACK) || self:GetOwner():KeyDown(IN_ATTACK2)) and self:Ammo1() > 0 then
		self:SetAttackDelay(math.Clamp(attdelay+0.1, 2, self.BarrelAccelTime))
	else
		self:SetAttackDelay(math.Clamp(attdelay-0.1, 2, self.BarrelAccelTime))
	end
	--self:CallOnClient("UpdateBonePositions", "nil")
	if CLIENT then
		self:UpdateBonePositions(self:GetOwner():GetViewModel())
	end
end

function SWEP:OnRemove()
	if self.LoopSound then self.LoopSound:Stop() end
	self:SetAttack(nil)
	local owner = self:GetOwner()
	if IsValid(self) and IsValid(owner) and owner:IsPlayer() then
		if game.SinglePlayer() and CLIENT then
			self:ResetBonePositions()
		else
			self:CallOnClient("ResetBonePositions")
		end
	end
end

function SWEP:SpecialHolster()
	self:OnRemove()
end

local lastpos = 0
local gunpos = Vector()

function SWEP:UpdateBonePositions(vm1)
	local vm = vm1 or self:GetOwner():GetViewModel()
	--print(vm)
	local barrels = vm:LookupBone("Bone Barrels")
	local gear = vm:LookupBone("Bone gear")
	--print(barrels, gear)
	if !barrels or !gear then return end
	local speed = 7
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		speed = 5
	end
	local attack = lastpos+self:GetAttackDelay()-2
	lastpos = Lerp(FrameTime()*40, lastpos, attack)
	local rotate = (attack*speed) %360
	vm:ManipulateBoneAngles(barrels, Angle(0,0,rotate))
	vm:ManipulateBoneAngles(gear, Angle(0,0,0-rotate))
end

function SWEP:AttackStuff()	
	self:Muzzleflash()
	self:TakeAmmo(1)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:UDSound()
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/minigun_1st.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/minigun_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/newweaponsounds/NewMinigunFire.wav")
SWEP.Primary.Special		= Sound("ut2004/weaponsounds/minigun/miniempty.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.05
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Cone 			= 0.075
SWEP.Primary.Damage 		= 7

SWEP.BarrelAccelTime		= 3.5

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/minigun/minialtfireb.wav")
SWEP.Secondary.Delay		= 0.15
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Damage 		= 15
SWEP.Secondary.Cone 			= 0.02

SWEP.DeploySound			= Sound("ut2004/weaponsounds/minigun/SwitchToMinigun.wav")

SWEP.MuzzleName				= ""
SWEP.LightForward			= 52
SWEP.LightRight				= 8
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(200, 200, 50)

SWEP.DelayBeforeShot = .8