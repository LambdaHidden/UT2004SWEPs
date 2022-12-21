

if SERVER then

	AddCSLuaFile("shared.lua")
	
end

if CLIENT then

	SWEP.PrintName			= "Mine Layer"			
	SWEP.Author				= "Hidden"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 2
	SWEP.UTSlot				= 7
	SWEP.Weight				= 9
	SWEP.ViewModelFOV		= 45
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/minelayer" )
	SWEP.UTBobScale			= .8
	language.Add("ammo_parasite_mines", "Spider Mines")
	
end

SWEP.Grenades = {}

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	util.PrecacheSound(self.Primary.Sound)
end

function SWEP:Equip(newown)
	for k, v in pairs(self.Grenades) do
		v:SetOwner(newown)
		v.Owner = newown
	end
end

function SWEP:Launch()
	if CLIENT then return end
	local own = self:GetOwner()
	
	if #self.Grenades == 8 then
		if IsValid(self.Grenades[1]) then
			self.Grenades[1]:Explode()
		else
			table.remove(self.Grenades, 1)
		end
	end
	
	local ent = ents.Create("ut2004_spidermine") -- Spawns the spider mine. Replace this with whatever name you gave them.
	local pos = own:GetShootPos()+own:GetRight() *8 -own:GetUp() *5 + own:GetAimVector()*36
	ent:SetPos(pos)
	ent:SetAngles(own:EyeAngles() - Angle(90,0,0))
	ent.Owner = own
	ent.OwnerGun = self
	ent:Spawn()
	ent:Activate()
	--ent.loco:Jump()
	ent.loco:SetVelocity(own:GetAimVector() *800)
	
	table.insert(self.Grenades, ent)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:AttackStuff()
	self:Launch()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:WeaponSound(self.Primary.Sound)
	self:SetIdleDelay(CurTime() + self:SequenceDuration())
end

function SWEP:SecondaryAttack()
	if table.IsEmpty(self.Grenades) then return end
	
	for k, v in pairs(self.Grenades) do
		if IsValid(v) then
			--v:Explode()
			v:SetTargetPos(self:GetOwner():GetEyeTrace().HitPos) -- Orders mines to scurry to the laser.
			v.TargetPainted = true
		end
	end
end

function SWEP:AttackStuff()	
	self:Muzzleflash()
	self:TakeAmmo(1)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:UDSound()
end

local LASER = Material('cable/redlaser') --'ut2004/xeffectmat/ion/painter_beam'

function SWEP:ViewModelDrawn(vm)
	local own = self:GetOwner()
	if own:KeyDown(IN_ATTACK2) then
		-- Draw the laser beam.
		render.SetMaterial( LASER )
		render.DrawBeam(vm:GetAttachment(1).Pos, own:GetEyeTrace().HitPos, 4, 0, 12.5, Color(255, 0, 0, 255))
	end
end

function SWEP:DrawWorldModel()
	self:DrawModel()
	local own = self:GetOwner()
	if own:KeyDown(IN_ATTACK2) then
		-- Draw the laser beam.
		render.SetMaterial( LASER )
		render.DrawBeam(self:GetAttachment(1).Pos, own:GetEyeTrace().HitPos, 4, 0, 12.5, Color(255, 0, 0, 255))
	end
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/onsweapons-a/minelayer_1st.mdl"
SWEP.WorldModel			= "models/ut2004/onsweapons-a/minelayer_3rd.mdl"

SWEP.Primary.Sound			= Sound("ut2004/onsvehiclesounds-s/spidermines/SpiderMineFire01.wav")
SWEP.Primary.Recoil			= .75
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.8
SWEP.Primary.DefaultClip	= 4
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_parasite_mines"

SWEP.Secondary.Delay		= 0.5
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/flakcannon/SwitchToFlakCannon.wav")

SWEP.MuzzleName				= "ut2004_mflash_flak"
SWEP.LightForward			= 46
SWEP.LightRight				= 8
SWEP.LightUp				= -13
SWEP.LightColor			= Vector(200, 200, 50)

SWEP.DelayBeforeShot = .8