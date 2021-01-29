

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
	self.Charge = 0
end

function SWEP:PrimaryAttack()
	if self.Owner:KeyDown(IN_ATTACK2) then return end
	if !self:CanPrimaryAttack() then return end
	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	--self:UTRecoil()
	self:EmitSound(self.Primary.Sound, 100, 100)
	self:MuzzleflashSprite()
	self:UDSound()
	self:DisableHolster()
	self:TakeAmmo()
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		pos = pos +ang:Forward() *10 +ang:Right() *6 +ang:Up() *-6
		local ent = ents.Create("ut2004_bio")
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self.Owner)
		--ent:SetModelScale(0.8, 0)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Right() *-12 +ang:Forward() *1450)
		end
	end
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	if self.Charge > 1.8 then
		self:StopSound(self.Secondary.Sound)
		return
	end
	
	if self.Charge == 0 then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	end
	self.Charge = self.Charge + 0.2
	self.ChargeSound = CreateSound(self.Owner, self.Secondary.Sound)
	self.ChargeSound:Play()
	
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:TakeAmmo()
end

function SWEP:SpecialThink()
	if self.Owner:KeyReleased(IN_ATTACK2) and self.Charge > 0 then
		self:SecondaryRelease(self.Charge)
	end
end

function SWEP:SecondaryRelease()
	self:SetNextPrimaryFire(CurTime() +self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() +self.Secondary.Delay)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	self:OnRemove()
	self:EmitSound(self.Primary.Sound, 100, 100)
	self:MuzzleflashSprite()
	self:UDSound()
	self:DisableHolster()
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector():Angle()
		pos = pos +ang:Right() *6 +ang:Up() *-6
		local ent = ents.Create("ut2004_bio")
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self.Owner)
		ent:SetModelScale(math.Clamp(self.Charge, 1, 2.2))
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(self.Charge*32)
			phys:SetVelocity(ang:Right() *-12 +ang:Forward() *1250)
		end
	end
	self.Charge = 0
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_biorifle.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_biorifle.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/BBioRifleFire.wav")
SWEP.Primary.Recoil			= .5
SWEP.Primary.Damage			= 35
SWEP.Primary.Delay			= .3
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_bio"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/biorifle_charge.wav")
SWEP.Secondary.Delay		= .25
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/SwitchToFlakCannon.wav")

SWEP.MuzzleName				= "ut2004_mflash_bio"
SWEP.LightForward			= 40
SWEP.LightRight				= 12
SWEP.LightUp				= -13