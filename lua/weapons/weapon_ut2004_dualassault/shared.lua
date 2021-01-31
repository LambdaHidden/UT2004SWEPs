

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Double Assault Rifles"			
	SWEP.Author				= "Hidden"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.UTSlot				= 2
	SWEP.Weight				= 2
	SWEP.ViewModelFOV		= 64
	SWEP.ViewModelFlip		= true
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/assault" )
	SWEP.UTBobScale			= .8
	--language.Add("ammo_flak_shells_ammo", "Flak Shells")
	--killicon.Add("weapon_ut2004_flak", "vgui/ut2004/flak", Color(255, 80, 0, 255))
	--killicon.Add("ut2004_flak2", "vgui/ut99/flak", Color(255, 80, 0, 255))
	
end

function SWEP:SpecialInit()
	--self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	
	self.GrenadeForce = 700
	self.ShouldFireGrenade = false
	
	self.UsedLeft = false
end

function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() +.6)
	self:SetNextSecondaryFire(CurTime() +.6)
	self:PlayDeploySound()
	self:SetIdleDelay(CurTime() +.3)

	local vm = self:GetOwner():GetViewModel( 1 )
	vm:SetWeaponModel( self.ViewModel, self )

	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SendSecondWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:OnRemove()
	if SERVER then
		local owner = self:GetOwner()
		if(owner && owner:IsValid() && owner:IsPlayer()) then
			owner:GetViewModel(1):AddEffects(EF_NODRAW)
		end
	end
end

function SWEP:Equip()
	self:GetOwner():StripWeapon("weapon_ut2004_assault")
end

function SWEP:SpecialHolster(wep)
	self:SendSecondWeaponAnim(ACT_VM_HOLSTER)
end

function SWEP:Grenade(force)	
	if CLIENT then return end
	local ent = ents.Create("ut2004_grenade")
	local pos = self:GetOwner():GetShootPos()
	local ang = self:GetOwner():GetAimVector():Angle()
	
	if self.UsedLeft then
		pos = pos +ang:Right() *-7 +ang:Up() *-8
	else
		pos = pos +ang:Right() *7 +ang:Up() *-8
	end
	
	ent:SetPos(pos)
	ent:SetAngles(self:GetOwner():EyeAngles())
	ent:SetOwner(self:GetOwner())
	ent:SetExplodeDelay(3)
	ent:Spawn()
	ent:Activate()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local vel = ang:Forward() *force +ang:Up() *128
		phys:ApplyForceCenter(vel)
	end	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:AttackStuff()
	self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, 1, self.Primary.Cone, 0)
	self:WeaponSound(self.Primary.Sound)
	self:SetIdleDelay(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
	if self:Ammo2() < 1 then return end
	self.GrenadeForce = math.Clamp(self.GrenadeForce + 10, 700, 1600)
	self.ShouldFireGrenade = true
end

function SWEP:SpecialThink()

	if self:GetOwner():KeyReleased(IN_ATTACK2) and self.ShouldFireGrenade then
		self.ShouldFireGrenade = false
		self:AttackStuff2()
		self.GrenadeForce = 700
	end

	local idle = self:GetIdleDelay()
	if idle > 0 and CurTime() > idle then
		self:SetIdleDelay(0)
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SendSecondWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:AttackStuff()	
	self:Muzzleflash()
	self:TakeAmmo()
	
	if self.UsedLeft then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		self.UsedLeft = false
	else
		self:SendSecondWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.UsedLeft = true
	end
	
	self:UDSound()
end

function SWEP:AttackStuff2()	
	self:Muzzleflash()
	self:TakeAmmo2()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:UDSound()
	
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)
	self:Grenade(self.GrenadeForce)
	if self.UsedLeft then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self.UsedLeft = false
	else
		self:SendSecondWeaponAnim(ACT_VM_SECONDARYATTACK)
		self.UsedLeft = true
	end
	self:WeaponSound(self.Secondary.Sound)
	self:SetIdleDelay(CurTime() + 0.542)
end

function SWEP:SendSecondWeaponAnim(anim)
	local owner = self:GetOwner()
		
	if (owner && owner:IsValid() && owner:IsPlayer()) then
	
		local vm = owner:GetViewModel(1)
	
		local idealSequence = self:SelectWeightedSequence(anim)
		local nextSequence = self:FindTransitionSequence(self:GetSequence(), idealSequence)
		
		vm:RemoveEffects(EF_NODRAW)

		if (nextSequence > 0) then
			vm:SendViewModelMatchingSequence(nextSequence)
		else
			vm:SendViewModelMatchingSequence(idealSequence)
		end

		return vm:SequenceDuration(vm:GetSequence())
	end
end

SWEP.HoldType			= "duel"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= false

SWEP.ViewModel			= "models/ut2004/weapons/v_assault.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_assault_dual.mdl"

SWEP.Primary.Sound			= "UT2004_AR.Fire"
SWEP.Primary.Damage			= 7
SWEP.Primary.Recoil			= .75
SWEP.Primary.Cone			= .09
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.08
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "9mmRound"

SWEP.Secondary.Sound		= Sound("ut2004/newweaponsounds/NewGrenadeShoot.wav")
SWEP.Secondary.Delay		= 0.2
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "SMG1_Grenade"
SWEP.Secondary.DefaultClip	= 4
SWEP.Secondary.ClipSize		= -1

SWEP.DeploySound			= Sound("ut2004/weaponsounds/SwitchToAssaultRifle.wav")

SWEP.MuzzleName				= ""
SWEP.LightForward			= 40
SWEP.LightRight				= 0
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(200, 200, 50)

SWEP.DelayBeforeShot = .8
