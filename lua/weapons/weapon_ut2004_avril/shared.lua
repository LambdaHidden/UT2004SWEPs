

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "AVRiL"			
	SWEP.Author				= "Hidden"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 1
	SWEP.UTSlot				= 8
	SWEP.Weight				= 11
	SWEP.ViewModelFOV		= 45
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/rocketlauncher" )
	language.Add("ammo_avril_rockets", "Anti-vehicle Rockets")
	--killicon.Add("ut99_rocket", "vgui/ut99/eight", Color(255, 80, 0, 255))
	
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	--util.PrecacheSound(self.Primary.Special)
	--util.PrecacheSound(self.Secondary.Sound)
end


function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local own = self:GetOwner()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:AttackStuff()
	self:FireRocket()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:WeaponSound(self.Primary.Sound)
	self:SetIdleDelay(CurTime() + self.Primary.Delay)
	self:SetHolsterDelay(CurTime() + 1)
	
	own:SetGroundEntity(nil)
	local fwd = Angle(0, own:GetAngles().y, 0):Forward()
	local grav = 1
	if own:GetGravity() > 0 then grav = own:GetGravity() end
	own:SetVelocity(Vector(fwd.x*-300, fwd.y*-300, grav*120))
	
	timer.Simple(1, function()
		if IsValid(self) and own:GetActiveWeapon() == self then
			self:EmitSound(self.Primary.Special, 75, 100, 1, CHAN_ITEM)
			self:SendWeaponAnim(ACT_VM_RELOAD)
		end
	end)
end

function SWEP:SecondaryAttack()
	local own = self:GetOwner()
	
	local trace = util.TraceLine({
		start = own:GetShootPos(),
		endpos = own:GetShootPos() + own:GetAimVector() * self.SeekDistance,
		filter = own
	})

	if !IsValid(trace.Entity) then
		trace = util.TraceHull({
		start = own:GetShootPos(),
		endpos = own:GetShootPos() + own:GetAimVector() * self.SeekDistance,
		filter = own,
		mins = Vector(-16, -16, -16),
		maxs = Vector(16, 16, 16)
		})
	end
	
	local target = trace.Entity
	
	if trace.Hit then
		if IsValid(target) and target:IsVehicle() then
			self.seekDelay = CurTime()
			if self.seek and (CurTime() - self.seek) > 1 then
				self.seek = CurTime() +0.25
				--if game.SinglePlayer() and CLIENT or !game.SinglePlayer() then self:EmitSound("ut2004/weaponsounds/BLockOn1.wav") end
				self:EmitSound("ut2004/weaponsounds/BLockOn1.wav")
				self.target = target
				self:SetNWBool("seekcrosshair", true)
			end		
		end
	end
	if !trace.Hit or trace.HitWorld then
		self.seek = CurTime()
		self.target = nil
	end
end

function SWEP:SpecialThink()
	if self.seekDelay and (CurTime() - self.seekDelay) >= 1 then
		self.seekDelay = nil
		self.target = nil
		--if game.SinglePlayer() and CLIENT or !game.SinglePlayer() then self:EmitSound("ut2004/weaponsounds/BSeekLost1.wav") end
		self:EmitSound("ut2004/weaponsounds/BSeekLost1.wav")
		self:SetNWBool("seekcrosshair", false)
	end
end

function SWEP:AttackStuff()	
	self:MuzzleflashSprite()
	self:TakeAmmo()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:UDSound()
end

function SWEP:FireRocket()
	if CLIENT then return end
	local own = self:GetOwner()
	
	local ang = own:EyeAngles()
	local pos = own:GetShootPos() + ang:Right() * 5 + ang:Up() * -4
	
	local ent = ents.Create("ut2004_avril_rocket")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetOwner(own)
	ent:Spawn()
	ent:Activate()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local vel = ent:GetForward() * 440 --Tweak this value!
		phys:ApplyForceCenter(vel)
	end
	if self.target and IsValid(self.target) then
		ent:SetTarget(self.target)
	end
end

SWEP.HoldType			= "rpg"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_avril.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_avril.mdl"

SWEP.Primary.Sound			= Sound("ut2004/onsvehiclesounds-s/AvrilFire01.wav")
SWEP.Primary.Special		= Sound("ut2004/onsvehiclesounds-s/AvrilReload01.wav")
--SWEP.Primary.Special2		= Sound("weapons/ut99/BRocketLauncherLoad.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.Delay			= 4.0
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_avril_rockets"

--SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/BRocketLauncherAltFire.wav")
SWEP.Secondary.Delay			= 0.2
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/SwitchToFlakCannon.wav")
SWEP.mode 					= "single"
SWEP.SeekDistance			= 4096
SWEP.MuzzleName				= "ut2004_mflash_flak"

SWEP.LightForward = 40
SWEP.LightRight = 8
SWEP.LightUp = -8