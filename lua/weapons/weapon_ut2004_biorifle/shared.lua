

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Bio Rifle"			
	SWEP.Author				= "Upset"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.UTSlot				= 3
	SWEP.Weight				= 3
	SWEP.ViewModelFOV		= 50
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/biorifle" )
	language.Add("ammo_bio_ammo", "Biosludge Ammo")
	--killicon.Add("ut99_bio", "vgui/ut99/bio", Color(255, 80, 0, 255))
	--killicon.Add("ut99_bio_small", "vgui/ut99/bio", Color(255, 80, 0, 255))
	
end

function SWEP:OnRemove()
	if self.ChargeSound then self.ChargeSound:Stop() end
end

function SWEP:SpecialInit()
	--self:SetHoldType(self.HoldType)
	self.GoopLoad = 0
end

function SWEP:AdjustSpeed()
	--[[
	local Velocity
	if self.GoopLevel < 1 then
        Velocity = Vector(Rotation) * Speed
    else
        Velocity = Vector(Rotation) * Speed * (0.4 + self.GoopLevel)/(1.4 * self.GoopLevel)
    Velocity.Z += TossZ
	end]]
	
	local Velocity
	if self.GoopLoad < 1 then
		Velocity = self.Force
	else
		Velocity = self.Force * (0.4 + self.GoopLoad)/(1.4 * self.GoopLoad)
	end
	return Velocity
end

function SWEP:PrimaryAttack()
	local own = self:GetOwner()
	if own:KeyDown(IN_ATTACK2) then return end
	if !self:CanPrimaryAttack() then return end
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	own:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	--self:UTRecoil()
	self:EmitSound(self.Primary.Sound, 100, 100)
	self:MuzzleflashSprite()
	self:UDSound()
	self:DisableHolster()
	self:TakeAmmo(1)
	if SERVER then
		local pos = own:GetShootPos()
		local dir = own:GetAimVector()
		pos = pos + dir *10 +own:GetRight() *6 +own:GetUp() *-6
		local ent = ents.Create("ut2004_bio")
		ent:SetAngles(own:EyeAngles())
		ent:SetPos(pos)
		ent:SetOwner(self:GetOwner())
		--ent:SetModelScale(0.8, 0)
		ent:SetGoopLevel(1)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(dir * self:AdjustSpeed())
		end
	end
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	if self.GoopLoad >= 10 then
		self:StopSound(self.Secondary.Sound)
		return
	end
	
	if self.GoopLoad == 0 then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	end
	self.GoopLoad = self.GoopLoad + 1
	self.ChargeSound = CreateSound(self:GetOwner(), self.Secondary.Sound)
	self.ChargeSound:Play()
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:TakeAmmo(1)
end

function SWEP:SpecialThink()
	if self:GetOwner():KeyReleased(IN_ATTACK2) and self.GoopLoad > 0 then
		self:SecondaryRelease(self.GoopLoad)
	end
end

function SWEP:SecondaryRelease()
	local own = self:GetOwner()
	self:SetNextPrimaryFire(CurTime() +self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	own:SetAnimation(PLAYER_ATTACK1)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	self:OnRemove()
	self:EmitSound(self.Primary.Sound, 100, 100)
	self:MuzzleflashSprite()
	self:UDSound()
	self:DisableHolster()
	if SERVER then
		local pos = own:GetShootPos()
		local dir = own:GetAimVector()
		pos = pos + dir *10 +own:GetRight() *6 +own:GetUp() *-6
		local ent = ents.Create("ut2004_bio")
		ent:SetAngles(own:EyeAngles())
		ent:SetPos(pos)
		ent:SetOwner(own)
		--ent:SetModelScale(math.Clamp(self.Charge, 1, 8))
		ent:SetGoopLevel(self.GoopLoad)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(dir * self:AdjustSpeed())
		end
	end
	self.GoopLoad = 0
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/biorifle_1st.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/biorifle_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/basefiringsounds/BBioRifleFire.wav")
SWEP.Primary.Recoil			= 0.5
SWEP.Primary.Damage			= 35
SWEP.Primary.Delay			= 0.33
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_bio"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/misc/biorifle_charge.wav")
SWEP.Secondary.Delay		= 0.25
SWEP.Secondary.Automatic	= true

SWEP.Force 					= 1222

SWEP.DeploySound			= Sound("ut2004/weaponsounds/flakcannon/SwitchToFlakCannon.wav")

SWEP.MuzzleName				= "ut2004_mflash_bio"
SWEP.LightForward			= 40
SWEP.LightRight				= 12
SWEP.LightUp				= -13