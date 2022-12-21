

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Grenade Launcher"			
	SWEP.Author				= "Hidden"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 2
	SWEP.UTSlot				= 7
	SWEP.Weight				= 9
	SWEP.ViewModelFOV		= 45
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/grenadelauncher" )
	SWEP.UTBobScale			= .8
	--language.Add("ammo_flak_shells_ammo", "Flak Shells")
	--killicon.Add("weapon_ut2004_flak", "vgui/ut2004/flak", Color(255, 80, 0, 255))
	--killicon.Add("ut2004_flak2", "vgui/ut99/flak", Color(255, 80, 0, 255))
	
end

SWEP.Grenades = {}

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("ut2004/weaponsounds/baseimpactandexplosions/BExplosion1.wav")
end

function SWEP:Equip(newown)
	for k, v in pairs(self.Grenades) do
		v:SetOwner(newown)
		v:SetVar("owner", newown)
	end
end

function SWEP:Launch()
	if CLIENT then return end
	
	if #self.Grenades == 8 then
		self.Grenades[1]:Explode()
		--table.remove(self.Grenades[1])
	end
	local own = self:GetOwner()
	local ent = ents.Create("ut2004_grenade2")
	local pos = own:GetShootPos()
	local ang = own:EyeAngles()
	pos = pos +ang:Right() *7 +ang:Up() *-5
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetOwner(own)
	ent.OwnerGun = self
	ent:Spawn()
	ent:Activate()		
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local vel = own:GetAimVector() *2800 --Tweak those values!
		phys:ApplyForceCenter(vel)
	end
	
	table.insert(self.Grenades, ent)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:AttackStuff()
	self:Launch()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:WeaponSound(self.Primary.Sound)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
end

function SWEP:SecondaryAttack()
	if #self.Grenades == 0 then return end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	for k, v in pairs(self.Grenades) do
		if IsValid(v) then
			v:Explode()
		end
	end
	--table.Empty(self.Grenades)
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

SWEP.ViewModel			= "models/ut2004/onsweapons-a/grenadelauncher_1st.mdl"
SWEP.WorldModel			= "models/ut2004/onsweapons-a/grenadelauncher_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/basefiringsounds/BBioRifleFire.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.8
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Grenade"

--SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/BFlakCannonAltFire.wav")
SWEP.Secondary.Delay		= 1
SWEP.Secondary.Automatic	= false

SWEP.DeploySound			= Sound("ut2004/weaponsounds/flakcannon/SwitchToFlakCannon.wav")

SWEP.MuzzleName				= "ut2004_mflash_flak"
SWEP.LightForward			= 46
SWEP.LightRight				= 8
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(200, 200, 50)

SWEP.DelayBeforeShot = .8