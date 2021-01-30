

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Rocket Launcher"			
	SWEP.Author				= "Upset"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 0
	SWEP.UTSlot				= 8
	SWEP.Weight				= 10
	SWEP.ViewModelFOV		= 50
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/rocketlauncher" )
	--killicon.Add("ut99_rocket", "vgui/ut99/eight", Color(255, 80, 0, 255))
	
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Primary.Special)
	util.PrecacheSound(self.Secondary.Sound)
	
	self.RocketCount = 0
	self.ShouldFireRocket = false
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	if self.Owner:KeyDown(IN_ATTACK2) then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.RocketCount = 1
	self:AttackStuff()
	self:FireRocket()
	self.RocketCount = 0
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	timer.Simple(self:SequenceDuration(), function()
		if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
			self:SendWeaponAnim(ACT_VM_DEPLOY_1)
			self:WeaponSound(self.Primary.Special, CHAN_ITEM)
		end
	end)
	self:WeaponSound(self.Primary.Sound)
	self:SetIdleDelay(CurTime() + 0.625)
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	
	if self.RocketCount == 2 or self:Ammo1() == 1 then
		self.RocketCount = self.RocketCount + 1
		self:FireRocket()
		self:AttackStuff2()
		self:TakeAmmo()
		self.ShouldFireRocket = false
		timer.Simple(self:SequenceDuration(), function()
			if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
				self:SendWeaponAnim(ACT_VM_DEPLOY_1)
				self:WeaponSound(self.Primary.Special, CHAN_ITEM)
			end
		end)
		return
	end
	
	self.RocketCount = self.RocketCount + 1
	self:TakeAmmo()
	self:SendWeaponAnim(ACT_VM_DEPLOY)
	self:WeaponSound("UT2004_RL.Open")
	timer.Simple(self:SequenceDuration(), function()
		if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
			--self:EmitSound(self.Primary.Special, 100, 100, 1, CHAN_ITEM)
			self:WeaponSound(self.Primary.Special, CHAN_ITEM)
			self:SendWeaponAnim(ACT_VM_DEPLOY_1)
		end
	end)
	self.ShouldFireRocket = true
end

function SWEP:SpecialThink()
	if self.Owner:KeyReleased(IN_ATTACK2) and self.ShouldFireRocket then
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		self.ShouldFireRocket = false
		--self:TakeAmmo()
		self:FireRocket(self.RocketCount)
		self:AttackStuff2()
	end
	
	local trace = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.SeekDistance,
		filter = self.Owner
	})

	if !IsValid(trace.Entity) then
		trace = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.SeekDistance,
		filter = self.Owner,
		mins = Vector(-16, -16, -16),
		maxs = Vector(16, 16, 16)
		})
	end
	
	local target = trace.Entity
	
	if trace.Hit then
		if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
			self.seekDelay = CurTime()
			if self.seek and (CurTime() - self.seek) > 1 then
				self.seek = CurTime() +.25
				if game.SinglePlayer() and CLIENT or !game.SinglePlayer() then self:EmitSound("ut2004/weaponsounds/BLockOn1.wav") end
				self.target = target
				self:SetNWBool("seekcrosshair", true)
			end		
		end
	end
	if !trace.Hit or trace.HitWorld then
		self.seek = CurTime()
		self.target = nil
	end
	
	if self.seekDelay and (CurTime() - self.seekDelay) >= 1 then
		self.seekDelay = nil
		if game.SinglePlayer() and CLIENT or !game.SinglePlayer() then self:EmitSound("ut2004/weaponsounds/BSeekLost1.wav") end		
		self:SetNWBool("seekcrosshair", false)
	end
end

function SWEP:AttackStuff()	
	self:MuzzleflashSprite()
	self:TakeAmmo()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:UDSound()
end

function SWEP:AttackStuff2()
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	timer.Simple(self:SequenceDuration(), function()
		if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
			self:WeaponSound(self.Primary.Special, CHAN_ITEM)
			self:SendWeaponAnim(ACT_VM_DEPLOY_1)
		end
	end)
	self:WeaponSound(self.Secondary.Sound)
	self:SetIdleDelay(CurTime() + 0.67)
	self.RocketCount = 0
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:FireRocket()
	if CLIENT then return end
	
	local ang1 = self.Owner:EyeAngles()
	local pos1 = self.Owner:GetShootPos() + ang1:Right() * 3 + ang1:Up() * -3
	
	local rockettbl = {
		[1] = {
			[1] = {
				pos = pos1,
				ang = ang1
			}
		},
		[2] = {
			[1] = {
				pos = pos1 + ang1:Right() * -2,
				ang = ang1 + Angle(0,4,0)
			},
			[2] = {
				pos = pos1 + ang1:Right() * 2,
				ang = ang1 + Angle(0,-4,0)
			}
		},
		[3] = {
			[1] = {
				pos = pos1,
				ang = ang1
			},
			[2] = {
				pos = pos1 + ang1:Right() * -4,
				ang = ang1 + Angle(0,6,0)
			},
			[3] = {
				pos = pos1 + ang1:Right() * 4,
				ang = ang1 + Angle(0,-6,0)
			}
		}		
	}
	
	local rockettbltrack = {
		[1] = {
			[1] = {
				pos = pos1,
				ang = ang1
			}
		},
		[2] = {
			[1] = {
				pos = pos1 + ang1:Right() * 4,
				ang = ang1
			},
			[2] = {
				pos = pos1 + ang1:Right() * -4,
				ang = ang1
			}
		},
		[3] = {
			[1] = {
				pos = pos1 + ang1:Up() * 3,
				ang = ang1
			},
			[2] = {
				pos = pos1 + ang1:Right() * 4 + ang1:Up() * -3,
				ang = ang1
			},
			[3] = {
				pos = pos1 + ang1:Right() * -4 + ang1:Up() * -3,
				ang = ang1
			}
		}		
	}
	
	for i = 1, self.RocketCount do
	
		local ent = ents.Create("ut2004_rocket")
		if self.Owner:KeyDown(IN_ATTACK) then
			ent:SetPos(rockettbltrack[self.RocketCount][i].pos)
			ent:SetAngles(rockettbltrack[self.RocketCount][i].ang)
		else
			ent:SetPos(rockettbl[self.RocketCount][i].pos)
			ent:SetAngles(rockettbl[self.RocketCount][i].ang)
		end
		ent:SetOwner(self.Owner)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			local vel = ent:GetForward() * 1200 --Tweak those values!
			phys:ApplyForceCenter(vel)
		end
		if self.target and IsValid(self.target) then
			ent:SetTarget(self.target)
		end
	
	end
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_rocketlauncher.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_rocketlauncher.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/BRocketLauncherFire.wav")
SWEP.Primary.Special		= Sound("ut2004/weaponsounds/RocketLauncherPlunger.wav")
--SWEP.Primary.Special2		= Sound("weapons/ut99/BRocketLauncherLoad.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.Delay			= 0.9
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "RPG_Round"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/BRocketLauncherAltFire.wav")
SWEP.Secondary.Delay			= 1.0
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/SwitchToRocketLauncher.wav")
SWEP.mode 					= "single"
SWEP.SeekDistance			= 4096
SWEP.MuzzleName				= "ut2004_mflash_flak"

SWEP.LightForward = 40
SWEP.LightRight = 8
SWEP.LightUp = -8
