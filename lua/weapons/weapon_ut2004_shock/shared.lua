

if SERVER then

	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

	SWEP.PrintName			= "Shock Rifle"			
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
	SWEP.UTSlot				= 4
	SWEP.Weight				= 4
	SWEP.ViewModelFOV		= 60
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/shockrifle" )
	language.Add( "ammo_asmd_ammo", "Shock Core" )
	--killicon.Add( "weapon_ut99_shock", "vgui/ut99/asmd", Color( 255, 80, 0, 255 ) )
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() and self.Primary.Ammo != "none" then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetIdleDelay(CurTime() + 0.5)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	--self:UTRecoil()
	self:DisableHolster()
	self:TakeAmmo()
	self:EmitSound(self.Primary.Sound, 75, 100, 0.4)
	if SERVER then
		self:GetOwner():LagCompensation(true)
	end
	self:UDSound()
	
	local ang = self:GetOwner():EyeAngles()
	local pos = self:GetOwner():GetShootPos()
	pos = pos +ang:Right() *6 -ang:Up() *4 + self:GetOwner():GetAimVector() * 16
	--local endpos = self:GetOwner():GetEyeTrace().HitPos
	--local dist = endpos:Distance(self:GetOwner():GetShootPos())*1.25
	--dist = math.min(dist, 20000)

	local tr = util.TraceLine({
		start = pos,
		endpos = self:GetOwner():GetEyeTrace().HitPos + self:GetOwner():GetAimVector()*16,
		filter = self:GetOwner()
	})

	local ef = EffectData()
		ef:SetStart(tr.StartPos)
		ef:SetAttachment(1)
		ef:SetOrigin(tr.HitPos)
		ef:SetEntity(self)
		--ef:SetAngles(self:GetOwner():EyeAngles())
		--ef:SetNormal(self:GetOwner():GetAimVector())
		ef:SetFlags(self.EffectSkin)
		util.Effect("ut2004_shock_beam", ef)
		util.Effect(self.MuzzleName, ef)
		self:Muzzleflash()

	self:DoHitEffect(tr)
	self:DoDamage(tr)
	
	if SERVER then
		self:GetOwner():LagCompensation(false)
	end
end

function SWEP:DoHitEffect(tr)
	if tr.Hit and tr.Entity:GetClass() != "ut2004_shockcore" and !tr.Entity:IsNPC() and !tr.Entity:IsPlayer() and !tr.Entity:IsNextBot() and IsFirstTimePredicted() then
		local effect = EffectData()
		effect:SetOrigin(tr.HitPos + tr.HitNormal)
		effect:SetAngles(tr.HitNormal:Angle())
		--util.Effect("ut99_asmd_exp", effect)
		util.Effect("ut2004_shock_ring", effect)
		util.Effect("ut2004_shock_hitglow", effect)
	end
end

function SWEP:DoDamage(tr)
	--local hit1, hit2 = tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal
	--util.Decal("FadingScorch", hit1, hit2)

	if SERVER and tr.HitNonWorld then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(self.Primary.Damage)
		dmginfo:SetDamageType(DMG_SHOCK)
		dmginfo:SetAttacker(self:GetOwner())
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageForce(self:GetOwner():GetUp() * 3500 + self:GetOwner():GetForward() * 30000)
		dmginfo:SetDamagePosition(tr.HitPos)
		tr.Entity:TakeDamageInfo(dmginfo)
	end
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:SetIdleDelay(CurTime() + 0.5)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	--self:UTRecoil()
	
	local flash2 = EffectData()
		flash2:SetOrigin(self:GetOwner():GetEyeTrace().HitPos)
		flash2:SetEntity(self:GetOwner())
		util.Effect("ut2004_mflash_shock2", flash2)
	
	self:TakeAmmo()
	self:EmitSound(self.Secondary.Sound, 100, 100, 0.4)
	self:UDSound()
	self:DisableHolster()
	if SERVER then
		local pos = self:GetOwner():GetShootPos()
		local ang = self:GetOwner():GetAimVector():Angle()
		pos = pos + ang:Right()*4 - ang:Up()*4
		local ent = ents.Create("ut2004_shockcore")
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self:GetOwner())
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Forward() *1000 +ang:Right() *-2)
		end
	end
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_shock.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_shock.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/BShockRifleFire.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.Damage			= 60
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= .7
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_asmd"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/BShockRifleAltFire.wav")
SWEP.Secondary.Delay		= .48
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/SwitchToShockRifle.wav")

SWEP.EffectSkin	= 0

SWEP.MuzzleName				= "ut2004_mflash_shock"
SWEP.LightForward			= 40
SWEP.LightRight				= 12
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(30, 50, 255)
