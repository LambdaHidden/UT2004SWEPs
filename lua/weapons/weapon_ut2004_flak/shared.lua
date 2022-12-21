

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Flak Cannon"			
	SWEP.Author				= "Upset & Hidden"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.UTSlot				= 7
	SWEP.Weight				= 9
	SWEP.ViewModelFOV		= 50
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/flak" )
	SWEP.UTBobScale			= .8
	language.Add("ammo_flak_shells_ammo", "Flak Shells")
	--killicon.Add("weapon_ut2004_flak", "vgui/ut2004/flak", Color(255, 80, 0, 255))
	--killicon.Add("ut2004_flak2", "vgui/ut99/flak", Color(255, 80, 0, 255))
	
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Secondary.Sound)
	util.PrecacheSound("ut2004/weaponsounds/baseimpactandexplosions/BExplosion1.wav")	
end

function SWEP:Flak()	
	if CLIENT then return end
	local ent = ents.Create("ut2004_flakshell")
	local pos = self:GetOwner():GetShootPos()
	local ang = self:GetOwner():EyeAngles()
	pos = pos +ang:Right() *7 +ang:Up() *-5
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetOwner(self:GetOwner())
	ent:Spawn()
	ent:Activate()		
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local vel = ang:Forward() *1300 +ang:Up() *128 --Tweak those values!
		phys:ApplyForceCenter(vel)
	end	
end

function SWEP:DoChunk(ang2, ang3, vel1, vel3)
	if CLIENT then return end
	local pos = self:GetOwner():GetShootPos()
	local ang = self:GetOwner():EyeAngles()
	pos = pos +ang:Right() *ang2 +ang:Up() *ang3
	local ent = ents.Create("ut2004_flakchunk")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetVar("owner",self:GetOwner())
	ent:SetOwner(self:GetOwner())
	ent:Spawn()
	ent:Activate()	
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(ang:Right() *vel1 * 1.5 +ang:Forward() *2100 +ang:Up() *vel3 * 1.5) --Tweak those values!
	end
end

function SWEP:FlakPrimary()
	self:DoChunk(10, -2, math.random(20,-120), math.random(-60,-20))
	self:DoChunk(8, math.random(-8,0), math.random(20,-120), math.random(-70,-20))
	self:DoChunk(math.random(0,5), math.random(-6,0), math.random(-100,40), math.random(-60,-20))
	self:DoChunk(math.random(2,8), math.random(-9,0), math.random(-30,70), math.random(-40,10))
	self:DoChunk(6, 0, math.random(-30,50), math.random(70,50))
	self:DoChunk(math.random(0,6), math.random(-6,0), math.random(20,-80), math.random(50,10))
	self:DoChunk(math.random(0,4), math.random(-5,0), math.random(10,-90), math.random(20,-5))
	self:DoChunk(math.random(8,2), -1, math.random(20,-110), math.random(60,20))
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:AttackStuff()
	self:FlakPrimary()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)	
	self:WeaponSound(self.Primary.Sound)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:AttackStuff()
	self:Flak()
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:WeaponSound(self.Secondary.Sound)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
end

function SWEP:AttackStuff()	
	self:Muzzleflash()
	self:TakeAmmo(1)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:UDSound()
end

SWEP.HoldType			= "crossbow"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/flak_1st.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/flak_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/basefiringsounds/BFlakCannonFire.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.8
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_flak_shells"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/basefiringsounds/BFlakCannonAltFire.wav")
SWEP.Secondary.Delay		= 1
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/flakcannon/SwitchToFlakCannon.wav")

SWEP.MuzzleName				= "ut2004_mflash_flak"
SWEP.LightForward			= 46
SWEP.LightRight				= 8
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(200, 200, 50)

SWEP.DelayBeforeShot = .8