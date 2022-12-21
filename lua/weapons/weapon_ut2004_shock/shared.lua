

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
	local own = self:GetOwner()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:SetIdleDelay(CurTime() + 0.5)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	own:SetAnimation(PLAYER_ATTACK1)
	--self:UTRecoil()
	self:DisableHolster()
	self:TakeAmmo(1)
	self:EmitSound(self.Primary.Sound, 75, 100, 0.4)
	if SERVER then
		own:LagCompensation(true)
	end
	self:UDSound()
	
	local pos = own:GetShootPos()+own:GetRight() *6 -own:GetUp() *4 + own:GetAimVector() * 16
	--local endpos = self:GetOwner():GetEyeTrace().HitPos
	--local dist = endpos:Distance(self:GetOwner():GetShootPos())*1.25
	--dist = math.min(dist, 20000)

	local tr = util.TraceLine({
		start = pos,
		endpos = own:GetEyeTrace().HitPos + own:GetAimVector()*16,
		filter = own
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
		own:LagCompensation(false)
	end
end

function SWEP:DoHitEffect(tr)
	if tr.Hit and tr.Entity:GetClass() != "ut2004_shockcore" and !tr.Entity:IsNPC() and !tr.Entity:IsPlayer() and !tr.Entity:IsNextBot() and IsFirstTimePredicted() then
		local effect = EffectData()
		effect:SetOrigin(tr.HitPos + tr.HitNormal)
		effect:SetNormal(tr.HitNormal)
		util.Effect("ut2004_shock_ring", effect)
		util.Effect("ut2004_shock_hitglow", effect)
	end
end

function SWEP:DoDamage(tr)
	--local hit1, hit2 = tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal
	--util.Decal("FadingScorch", hit1, hit2)

	if SERVER and tr.HitNonWorld then
		local own = self:GetOwner()
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(self.Primary.Damage)
		dmginfo:SetDamageType(DMG_SHOCK)
		dmginfo:SetAttacker(own)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageForce(own:GetUp() * 3500 + own:GetAimVector() * 30000)
		dmginfo:SetDamagePosition(tr.HitPos)
		tr.Entity:TakeDamageInfo(dmginfo)
	end
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() then return end
	local own = self:GetOwner()
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:SetIdleDelay(CurTime() + 0.5)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	own:SetAnimation(PLAYER_ATTACK1)
	--self:UTRecoil()
	
	local flash2 = EffectData()
		flash2:SetOrigin(own:GetEyeTrace().HitPos)
		flash2:SetEntity(own)
		util.Effect("ut2004_mflash_shock2", flash2)
	
	self:TakeAmmo(1)
	self:EmitSound(self.Secondary.Sound, 100, 100, 0.4)
	self:UDSound()
	self:DisableHolster()
	if SERVER then
		local pos = own:GetShootPos() + own:GetRight()*4 - own:GetUp()*4
		local ent = ents.Create("ut2004_shockcore")
		ent:SetAngles(own:EyeAngles())
		ent:SetPos(pos)
		ent:SetOwner(own)
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(own:GetAimVector() * 1000 - own:GetRight() * 2)
		end
	end
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/newweapons2004/shockrifle.mdl"
SWEP.WorldModel			= "models/ut2004/newweapons2004/newshockrifle_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/basefiringsounds/BShockRifleFire.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.Damage			= 60
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= .7
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_asmd"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/basefiringsounds/BShockRifleAltFire.wav")
SWEP.Secondary.Delay		= .48
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/shockrifle/SwitchToShockRifle.wav")

SWEP.EffectSkin	= 0

SWEP.MuzzleName				= "ut2004_mflash_shock"
SWEP.LightForward			= 40
SWEP.LightRight				= 12
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(30, 50, 255)