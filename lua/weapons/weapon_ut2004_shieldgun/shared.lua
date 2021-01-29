

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Shield Gun"			
	SWEP.Author				= "Hidden"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 0
	SWEP.UTSlot				= 1
	SWEP.Weight				= 1
	SWEP.ViewModelFOV		= 64
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/shieldgun" )
	SWEP.UTBobScale			= .8
	--language.Add("ammo_flak_shells_ammo", "Flak Shells")
	--killicon.Add("weapon_ut2004_flak", "vgui/ut2004/flak", Color(255, 80, 0, 255))
	--killicon.Add("ut2004_flak2", "vgui/ut99/flak", Color(255, 80, 0, 255))
	
end

function SWEP:SpecialInit()
	--self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Secondary.Sound)
	
	self.Charge = 0
	self.ReturnAmmoTime = 0
end

function SWEP:OnRemove()
	self:SetAttack(nil)
	self:SetSecAttack(nil)
	self:SetAttackDelay(0)
	if self.LoopSound then self.LoopSound:Stop() end
	if self.LoopSound1 then self.LoopSound1:Stop() end
end


function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	--self:AttackStuff()
	if !self:GetAttack() then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		if !self.LoopSound1 then
			self.LoopSound1 = CreateSound(self.Owner, self.Primary.Special)
			self.LoopSound1:SetSoundLevel(80)
		end
		self.LoopSound1:Play()
		self:SetAttack(true)
		
		local eff = EffectData()
		eff:SetEntity(self.Owner)
		util.Effect("ut2004_shield_model", eff)
	end
	
	self:TakeAmmo()
	--self:SetIdleDelay(CurTime() + self:SequenceDuration())
end

function SWEP:PrimaryAttack()
	if CurTime() < self:GetNextPrimaryFire() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self.Charge == 0 then
		self:SendWeaponAnim(ACT_VM_PULLBACK)
		
		self:CallOnClient("DoChargeParticles")
		
		if !self.LoopSound then
			self.LoopSound = CreateSound(self.Owner, self.Secondary.Sound)
			self.LoopSound:SetSoundLevel(80)
		end
		self.LoopSound:Play()
	end
	
	if self.Charge >= 115 then
		if !self:GetSecAttack() then
			self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
			self:SetSecAttack(true)
		end
		return 
	end
	
	self.Charge = self.Charge + 5
	
	--self:Punch(30, true, 128)
end

function SWEP:SpecialThink()

	if (self.Owner:KeyReleased(IN_ATTACK2) || self:Ammo1() < 1) and self:GetAttack() then
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetAttack(false)
		if self.LoopSound1 then self.LoopSound1:Stop() end
	end
	
	if SERVER and self:Ammo1() < 100 and CurTime() > self.ReturnAmmoTime and !self.Owner:KeyDown(IN_ATTACK2) then
		self.Owner:GiveAmmo(1, self.Primary.Ammo, true)
		self.ReturnAmmoTime = CurTime() + self.Secondary.Delay
	end
	
	if self.Owner:KeyReleased(IN_ATTACK) and self.Charge > 0 then
		self:Punch(self.Charge + 35, true, 128)
		self.Charge = 0
		self:SetSecAttack(nil)
		if self.LoopSound then self.LoopSound:Stop() end
	end
	
end

function SWEP:Punch(damage, secondary, hitdist)
	local bullet = {}
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector(0,0,0)
		bullet.Tracer = 0
		bullet.Force = 0
		bullet.Damage = 0
		
	
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	self:CallOnClient("DoMuzzleParticles")
	
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:UDSound()

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:EmitSound(self.Primary.Sound, 85, 100)
	
	if self.LoopSound then self.LoopSound:Stop() end
		
	if SERVER then self.Owner:LagCompensation(true) end
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * hitdist,
		filter = self.Owner
	})

	if !IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * hitdist,
			filter = self.Owner,
			mins = Vector(-4, -4, -5),
			maxs = Vector(4, 4, 5)
		})
	end
	
	local dmginfo = DamageInfo()

	if tr.HitNonWorld then
		if CLIENT then return end
		local attacker = self.Owner
		if (!IsValid(attacker)) then attacker = self end
		dmginfo:SetAttacker(attacker)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(damage)
		dmginfo:SetDamageForce(self.Owner:GetUp() *4000 +self.Owner:GetForward() *22000 +self.Owner:GetRight() *-1000)
		tr.Entity:TakeDamageInfo(dmginfo)
	end
	if tr.HitWorld then
		if !secondary then
			self.Owner:FireBullets(bullet)
		end
		dmginfo:SetAttacker(self.Owner)
		dmginfo:SetDamageType(DMG_CLUB)
		dmginfo:SetDamage(damage*0.36)
		dmginfo:SetDamageForce(self.Owner:GetUp() -self.Owner:GetForward() *9)
		util.BlastDamageInfo(dmginfo, tr.HitPos, hitdist)
		local Force = dmginfo:GetDamageForce()
		local dmg = dmginfo:GetDamage()
		self.Owner:SetVelocity(dmg*Force)
	end
	if SERVER then self.Owner:LagCompensation(false) end
	--self:UTRecoil()
	self:DisableHolster()
end

function SWEP:DoMuzzleParticles()
	self.Owner:GetViewModel():StopParticles()
	self:StopParticles()
	if CLIENT then
		if LocalPlayer():GetViewEntity() == self.Owner then
			ParticleEffectAttach( "ut2004_shieldgun_muzzle", PATTACH_POINT_FOLLOW, self.Owner:GetViewModel(), 1 )
		else
			ParticleEffectAttach( "ut2004_shieldgun_muzzle", PATTACH_POINT_FOLLOW, self.Owner:GetActiveWeapon(), 1 )
		end
	end
end

function SWEP:DoChargeParticles()
	self.Owner:GetViewModel():StopParticles()
	self:StopParticles()
	if CLIENT then
		if LocalPlayer():GetViewEntity() == self.Owner then
			ParticleEffectAttach( "ut2004_shieldgun_charge", PATTACH_POINT_FOLLOW, self.Owner:GetViewModel(), 1 )
		else
			ParticleEffectAttach( "ut2004_shieldgun_charge", PATTACH_POINT_FOLLOW, self.Owner:GetActiveWeapon(), 1 )
		end
	end
end

hook.Add("EntityTakeDamage", "UT2004ShieldDamage", function(target, dmginfo)
	if target:IsPlayer() then
		--print("isplayer")
		local wep = target:GetActiveWeapon()
		local shield = IsValid(wep) and wep:GetClass() == "weapon_ut2004_shieldgun" and wep:GetAttack()
		--print(wep)
		if shield then
			--print(shield)
			local dot = (dmginfo:GetInflictor():GetPos() - target:GetPos()):GetNormalized():Dot(target:GetAimVector())
			if dot >= 0.75 then
				local dmg = dmginfo:GetDamage()
				dmginfo:SetDamage(math.Clamp(dmg - 100, 0, dmg))
				wep:TakePrimaryAmmo(dmg * 0.25)
				if dmginfo:GetDamage() == 0 then return true end
			end
		end
		
		if target:Armor() <= 100 then
			target.UT2K4UShield = nil
			target:SetNWBool("UT2K4UShield", false)
		else
			target:SetArmor(target:Armor() - dmginfo:GetDamage())
			target:EmitSound("ut2004/weaponsounds/ArmorHit.wav", 80, 100)
			return true
		end
	end
end)

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_shieldgun.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_shieldgun.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/BShieldGunFire.wav")
SWEP.Primary.Special			= Sound("ut2004/weaponsounds/BShield1.wav")
SWEP.Primary.Damage			= 7
SWEP.Primary.Recoil			= .75
SWEP.Primary.Cone			= .09
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Battery"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/shieldgun_charge.wav")
SWEP.Secondary.Delay		= 0.2
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/shieldgun_change.wav")

SWEP.DelayBeforeShot = .8