

if SERVER then

	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

	SWEP.PrintName			= "Instagib Rifle"			
	SWEP.Author				= "Upset"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 0
	SWEP.UTSlot				= 4
	SWEP.Weight				= 4
	SWEP.ViewModelFOV		= 60
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/shockrifle" )
	--language.Add( "ammo_asmd_ammo", "Shock Core" )
	--killicon.Add( "weapon_ut99_shock", "vgui/ut99/asmd", Color( 255, 80, 0, 255 ) )
	
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() and self.Primary.Ammo != "none" then return end
	local own = self:GetOwner()
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
		own:LagCompensation(true)
	end
	self:UDSound()
	
	local ang = own:EyeAngles()
	local pos = own:GetShootPos()
	pos = pos +ang:Right() *6 -ang:Up() *4 + own:GetAimVector() * 16
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
		local col = ColorToHSV(own:GetPlayerColor():ToColor())*0.7
		ef:SetColor(col)
		util.Effect("ut2004_shock_beam", ef)
		util.Effect(self.MuzzleName, ef)
		--self:Muzzleflash()

	--self:DoHitEffect(tr)
	self:DoDamage(tr)
	
	if SERVER then
		own:LagCompensation(false)
	end
end

function SWEP:SecondaryAttack()
	if !self:CanPrimaryAttack() and self.Primary.Ammo != "none" then return end
	local own = self:GetOwner()
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
		own:LagCompensation(true)
	end
	self:UDSound()
	
	local ang = own:EyeAngles()
	local pos = own:GetShootPos()
	pos = pos +ang:Right() *6 -ang:Up() *4 + own:GetAimVector() * 16
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
		local col = ColorToHSV(own:GetPlayerColor():ToColor())*0.7
		ef:SetColor(col)
		util.Effect("ut2004_shock_beam", ef)
		util.Effect(self.MuzzleName, ef)
		--self:Muzzleflash()

	--self:DoHitEffect(tr)
	self:DoDamage(tr)
	
	if SERVER then
		own:LagCompensation(false)
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
	local own = self:GetOwner()
	if SERVER and tr.HitNonWorld then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(self.Primary.Damage)
		dmginfo:SetDamageType(DMG_ALWAYSGIB)
		dmginfo:SetAttacker(own)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamageForce(own:GetUp() * 3500 + own:GetForward() * 30000)
		dmginfo:SetDamagePosition(tr.HitPos)
		tr.Entity:TakeDamageInfo(dmginfo)
	end
end

function SWEP:ResetSkin()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	local vm = owner:GetViewModel()
	if not vm:IsValid() then return end
	vm:SetSkin(0)
end

function SWEP:PreDrawViewModel(vm)
	vm:SetSkin(1)
end

function SWEP:OnRemove()
	
	if game.SinglePlayer() then
		self:CallOnClient("ResetSkin")
	else
		if CLIENT and IsValid(self:GetOwner()) then
			self:ResetSkin()
		end
	end
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_shock.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_shock.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/instagib_rifleshot.wav")
SWEP.Primary.Recoil			= .4
SWEP.Primary.Damage			= 300
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 1.0
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_asmd"

SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/instagib_rifleshot.wav")
SWEP.Secondary.Delay		= .75
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/SwitchToShockRifle.wav")

SWEP.EffectSkin	= 1

SWEP.MuzzleName				= ""
SWEP.LightForward			= 40
SWEP.LightRight				= 12
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(30, 50, 255)
