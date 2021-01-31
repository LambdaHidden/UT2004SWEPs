
if SERVER then

	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

	SWEP.PrintName			= "Redeemer"			
	SWEP.Author				= "Upset"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 0
	SWEP.UTSlot				= 10
	SWEP.Weight				= 11
	SWEP.ViewModelFOV		= 75
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/redeemer" )
	language.Add("ammo_redeemer_ammo", "Redeemer Ammo")
	
end

function SWEP:AttackStuff()	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	--self:Muzzleflash()
	self:EmitSound(self.Primary.Sound, 100, 100)
	self:UDSound()
	--self:UTRecoil()
	self:DisableHolster()
	if !self:GetOwner():IsNPC() then self:TakePrimaryAmmo(1) end
end

function SWEP:Restricted()
	self:SetNextPrimaryFire(CurTime() + 2)
	self:SetNextSecondaryFire(CurTime() + 2)
	if !self:GetOwner():IsNPC() then self:GetOwner():PrintMessage(HUD_PRINTCENTER, "Redeemer is restricted!") end
end

function SWEP:PrimaryAttack()
	if SERVER then
		if self.IsGuidingNuke and self.Rocket and self.Rocket:IsValid() then
			self:ExplodeInAir()
			return
		end
	end

	if !self:CanPrimaryAttack() then return end
	if cvars.Bool("ut2k4_restrictredeemer") then
		self:Restricted()
		return
	end
	
	if !self:GetOwner():IsNPC() then
		if !self.IsGuidingNuke and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
			self:AttackStuff()
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		end
	else
		self:EmitSound(self.Primary.Sound, 100, 100)
	end
	
	if SERVER then	
		local pos = self:GetOwner():GetShootPos()
		local ang = self:GetOwner():EyeAngles()
		pos = pos +ang:Right() *4 +ang:Up() *-7
		local ent = ents.Create("ut2004_redeemer")
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:SetOwner(self:GetOwner())
		ent:Spawn()
		ent:Activate()
		ent:EmitSound(self.Primary.Sound, 100, 100)
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Forward() *900)
		end
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		if self.IsGuidingNuke and self.Rocket and self.Rocket:IsValid() then
			self:ExplodeInAir()
			return
		end	

		local PlayerPos = self:GetOwner():GetShootPos()
		local PlayerAng = self:GetOwner():GetAimVector()
		local PlayerRight = self:GetOwner():GetRight()

		if !self:CanPrimaryAttack() then return end
		
		if cvars.Bool("ut2k4_restrictredeemer") then
			self:Restricted()
			return
		end
		
		self.Rocket = ents.Create("ut2004_redeemer")
		self.Rocket:SetOwner(self:GetOwner())
		self.Rocket:SetPos(PlayerPos)
		self.Rocket:SetAngles(PlayerAng:Angle())
		self.Rocket:Spawn()
		self.Rocket:Activate()
		self.Rocket:EmitSound(self.Primary.Sound, 100, 100)
		
		self.RocketPhysObj = self.Rocket:GetPhysicsObject()
		self.RocketPhysObj:SetVelocity(PlayerAng*512 - 16*PlayerRight + Vector(0,0,256))
	end

	if !self.IsGuidingNuke and self:Ammo1() > 0 then
		self:AttackStuff()
	end
	self:StartGuiding()
	
	self:SetNWEntity("rocket", self.Rocket)
end

function SWEP:ExplodeInAir()
	self:StopGuiding()
	self.Rocket:Explode()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SpecialThink()
	if self:Ammo1() > 1 then
		self:GetOwner():SetAmmo(1, self.Primary.Ammo)
	end

	if self.IsGuidingNuke and self.Rocket and self.Rocket:IsValid() then
		local PlayerAng = self:GetOwner():GetAimVector()
		local angles = LerpAngle(.015, self.Rocket:GetAngles(), PlayerAng:Angle())
		local vec = LerpVector(.01, self.Rocket:GetForward(), PlayerAng)*700
		self.Rocket:SetAngles(angles)
		self.RocketPhysObj:SetVelocity(vec)
		
		local ViewEnt = self:GetOwner():GetViewEntity()
		
		if self.DrawReticle and ViewEnt ~= self.Rocket then
			self.DrawReticle = false
			self:SetNWBool("DrawReticle",false)
		end
		
		if not self.DrawReticle and ViewEnt == self.Rocket then
			self.DrawReticle = true
			self:SetNWBool("DrawReticle",true)
		end
		
		if ViewEnt == self:GetOwner() or ViewEnt == NULL then
			self:GetOwner():SetViewEntity(self.Rocket) 
		end
	else
		self:StopGuiding()
	end
end

function SWEP:StartGuiding()
	if not self.Rocket or self.Rocket == NULL then return end

	self.LastAng = self:GetOwner():EyeAngles()
	self:GetOwner():SetEyeAngles(self.Rocket:GetAngles())
	
	self.IsGuidingNuke = true
	self.DrawReticle = true
	self:SetNWBool("DrawReticle",true)
	self:GetOwner():SetViewEntity(self.Rocket)
	
	if SERVER then
		self:GetOwner():DrawViewModel(false)
	end
end

function SWEP:StopGuiding()
	if not self.IsGuidingNuke then return end

	self.IsGuidingNuke = false
	self.DrawReticle = false
	self:SetNWBool("DrawReticle",false)

	umsg.Start("ExplodedBool", self:GetOwner())
	umsg.End()
	
	self:GetOwner():SetViewEntity(self:GetOwner())
	
	if SERVER then
		self:GetOwner():DrawViewModel(true)
	end
	
	self:GetOwner():SetEyeAngles(self.LastAng)	
end

if CLIENT then

local Outer = surface.GetTextureID("vgui/ut2004/RedeemerOuterScope")
local Inner = surface.GetTextureID("vgui/ut2004/RedeemerInnerScope")
local Edge = surface.GetTextureID("vgui/ut2004/RedeemerOuterEdge")
local static = surface.GetTextureID("vgui/ut2004/static_a")

function SWEP:DrawHUD()
	local x, y = ScrW() * 0.5, ScrH() * 0.5
	
	if self:GetNWBool("DrawReticle") then
		local ent = self:GetNWEntity("rocket")
		
		surface.SetDrawColor(255, 255, 255, 255)
		
		if IsValid(ent) then
			surface.SetTexture(Inner)
			surface.DrawTexturedRectRotated(x, y, ScrH(), ScrH(), ent:GetAngles().r) --Inner Crosshair
		end
		surface.SetTexture(Outer)
		surface.DrawTexturedRect(x - y, 0, ScrH(), ScrH()) --Outer Crosshair
		
		surface.SetTexture(Edge)
		surface.DrawTexturedRect(x - y, 0, y, y) --Top Left
		surface.DrawTexturedRectUV( x, 0, y, y, 1, 0, 0, 1 ) --Top Right
		surface.DrawTexturedRectUV( x - y, y, y, y, 0, 1, 1, 0 ) --Bottom Left
		surface.DrawTexturedRectUV( x, y, y, y, 1, 1, 0, 0 ) --Bottom Right
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, x - y, ScrH()) --Left Edge
		surface.DrawRect(x + y, 0, x - y, ScrH()) --Right Edge
		
		/*
		local ent = self:GetNWEntity("rocket")
		if IsValid(ent) then
			local findents = ents.FindInSphere(ent:GetPos(), 3000)
			for k, v in pairs(findents) do
				if IsValid(v) and (v:IsNPC() or (v:IsPlayer() and v:Alive())) then
					local entspos = v:GetPos()
					local dist = ent:GetPos():Distance(entspos)
					local pos = entspos + Vector(20,0,50)
					pos = pos:ToScreen()
					surface.SetTexture(targetch)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(pos.x, pos.y, 16, 16)
					draw.SimpleText(math.Round(dist*100000), "default", pos.x-6, pos.y+12, Color(255,0,0,255))
				end
			end
		end
		*/
	end
	
	if self:GetOwner():GetNWBool("exploded") then
		surface.SetTexture(static)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end
end

usermessage.Hook("ExplodedBool", function(msg)
	local ply = LocalPlayer()
	ply:SetNWBool("exploded", true)
	timer.Simple(.3, function()
		ply:SetNWBool("exploded", false)
	end)
end)

end

function SWEP:OnRemove()
	self:StopGuiding()
end

SWEP.HoldType			= "shotgun"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_redeemer.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_redeemer.mdl"

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/redeemer_shoot.wav")
SWEP.Primary.Recoil			= 1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_redeemer"

SWEP.Secondary.Delay		= 1
SWEP.Secondary.Automatic	= true

SWEP.DeploySound			= Sound("ut2004/weaponsounds/redeemer_change.wav")

SWEP.LightForward = 40
SWEP.LightRight = 6
SWEP.LightUp = -5

SWEP.Rocket = SWEP.Rocket or NULL
SWEP.IsGuidingNuke = false
SWEP.DrawReticle = false
SWEP.LastAng = Vector(0,0,0)
