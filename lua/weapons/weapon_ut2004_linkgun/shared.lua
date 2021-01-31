

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Link Gun"			
	SWEP.Author				= "Upset & Hidden"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.UTSlot				= 5
	SWEP.Weight				= 5
	SWEP.ViewModelFOV		= 50
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/linkgun" )
	language.Add("ammo_pulse_cell_ammo", "Link Ammo")
	--killicon.Add("weapon_ut99_pulsegun", "vgui/ut99/pulsegun_icon", Color(255, 80, 0, 255))
	
end

function SWEP:SpecialInit()
	--self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound(self.Secondary.Sound)
	self:GetOwner():SetNWInt("LinkGunLinks", 0)
	self.Link = nil
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:AttackStuff()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)	
	self:WeaponSound(self.Primary.Sound)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
	self:UDSound()
	
	if SERVER then
		local pos = self:GetOwner():GetShootPos()
		local ang = self:GetOwner():GetAimVector():Angle()
		pos = pos +ang:Right() *math.random(4,8) +ang:Up() *math.random(0,-6)
		local ent = ents.Create("ut2004_link_proj")
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self:GetOwner())
		ent.Links = self:GetOwner():GetNWInt("LinkGunLinks")
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Forward() *1000)
		end
	end
end

function SWEP:SecondaryAttack()
	if self:Ammo1() < 1 then return end

	if !self:GetSecAttack() then
		if !self.LoopSound or (self.LoopSound and !self.LoopSound:IsPlaying()) then
			self.LoopSound = CreateSound(self:GetOwner(), self.Secondary.Sound)
			self.LoopSound:SetSoundLevel(100)
			self.LoopSound:Play()
			local fx = EffectData()
			fx:SetEntity(self:GetOwner())
			self.Effect = util.Effect("ut2004_link_beam", fx)
		end
		self:UDSound()
	end
	
	self:SetSecAttack(true)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:TakeAmmo()
	self:DisableHolster(.08)
end

function SWEP:Beam()
	if self:GetOwner():KeyDown(IN_ATTACK) then return end
	if !self:CanPrimaryAttack() then return end
	
	if self.Link != nil then 
		
		return 
	end
	
	if SERVER then self:GetOwner():LagCompensation(true) end
	local tr = util.TraceLine({
		start = self:GetOwner():GetShootPos(),
		endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDist,
		filter = self:GetOwner()
	})
		
	if SERVER then
		if tr.HitNonWorld then
			if tr.Entity:IsPlayer() and tr.Entity:Team() == self:GetOwner():Team() then
				self.Link = tr.Entity
				--table.insert(self.Link.LinkGunLinks, self:GetOwner())
				self.Link:SetNWInt("LinkGunLinks", self.Link:GetNWInt("LinkGunLinks") + 1)
			else
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(self.Secondary.Damage * (1 + self:GetOwner():GetNWInt("LinkGunLinks") * 1.5) * engine.TickInterval())
				dmginfo:SetDamageType(DMG_ENERGYBEAM)
				dmginfo:SetAttacker(self:GetOwner())
				dmginfo:SetInflictor(self)
				dmginfo:SetDamagePosition(tr.HitPos)
				--dmginfo:SetDamageForce(self:GetOwner():GetUp() * 3500 + self:GetOwner():GetForward() * 10000)
				tr.Entity:TakeDamageInfo(dmginfo)
			end
		end
		self:GetOwner():LagCompensation(false)
	end
	--util.ParticleTracerEx( "ut2004_link_beam", tr.StartPos, tr.HitPos, false, self:EntIndex(), 1 )
	
	--local hit1, hit2 = tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal
	--util.Decal("FadingScorch", hit1, hit2)
	self.HitDist = math.Clamp(self.HitDist * 1.25, self.HitDistMin, self.HitDistMax)
	self:SetNWFloat("HitDist", self.HitDist)
	self:SetNWVector( "LinkHitPos", tr.HitPos )
	
	if !cvars.Bool("ut2k4_lighting") or !CLIENT then return end
	local dynlight = DynamicLight(self:EntIndex())
		dynlight.Pos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 40
		dynlight.Size = 80
		dynlight.Decay = 0
		dynlight.R = 50
		dynlight.G = 255
		dynlight.B = 40
		dynlight.Brightness = 2
		dynlight.DieTime = CurTime()+.1
end
/*
function SWEP:UpdateLinks(ply, adding)
	if table.HasValue(self.Links, ply) then
		if !adding then
			table.RemoveByValue(self.Links, ply)
		end
	else
		if adding then
			table.insert(self.Links, ply)
		end
	end
end
*/
function SWEP:SpecialThink()
	if self:GetSecAttack() and self:GetOwner():KeyReleased(IN_ATTACK2) then
		self:SetSecAttack(false)
		if self.LoopSound then self.LoopSound:Stop() end
		if self.Effect then self.Effect:Remove() end
		
		if self.Link != nil then
			--table.RemoveByValue(self.Link.LinkGunLinks, self:GetOwner())
			self.Link:SetNWInt("LinkGunLinks", self.Link:GetNWInt("LinkGunLinks") - 1)
			self.Link = nil
		end
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
	if self:GetSecAttack() then
		if self:GetSecAttack() then
			self:Beam()
		end
	end
end

function SWEP:AttackStuff()	
	self:MuzzleflashSprite()
	self:TakeAmmo()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	--self:UDSound()
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_linkgun.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_linkgun.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/BPulseRifleFire.wav")
--SWEP.Primary.Special		= Sound("Weapon_UT99.PulseDown")
SWEP.Primary.Recoil			= .2
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= .2
SWEP.Primary.DefaultClip	= 60
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_pulse_cell"

SWEP.Secondary.Damage		= 82.5
SWEP.Secondary.Sound		= Sound("ut2004/weaponsounds/BLinkGunBeam1.wav")
SWEP.Secondary.Delay		= .2
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Cone			= 0

SWEP.DeploySound			= Sound("ut2004/newweaponsounds/NewLinkSelect.wav")

SWEP.MuzzleName				= "ut2004_mflash_link"
SWEP.LightForward			= 42
SWEP.LightRight				= 10
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(50, 255, 40)

SWEP.HitDist				= 64
SWEP.HitDistMin				= 64
SWEP.HitDistMax				= 810
