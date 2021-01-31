

if SERVER then

	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

	SWEP.PrintName			= "Translocator"			
	SWEP.Author				= "Upset & Hidden"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.UTSlot				= 1
	SWEP.ViewModelFOV		= 70
	SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/ut2004/translocator" )
	--killicon.Add("weapon_ut99_translocator", "vgui/ut99/transloc", Color(255, 80, 0, 255))
	
end

function SWEP:SpecialDT()
	self:NetworkVar("Bool", 3, "Zoom")
end

function SWEP:SpecialInit()
	--self:SetHoldType(self.HoldType)
	--self:SetHolstering(false)
	self.ReturnAmmoTime = 0
end
/*
function SWEP:Deploy()
	self:SetNextPrimaryFire(CurTime() +.1)
	self:SetNextSecondaryFire(CurTime() +.1)
	self:SendWeaponAnim(ACT_VM_DRAW)
	if !self:GetAttack() then
		self:SetIdleDelay(CurTime() +.2)
	else
		self:SetIdleDelay(CurTime() +.01)
	end	
	return true
end
*/
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	if CLIENT then return end
	
	local own = self:GetOwner()
	
	local pos = own:GetShootPos()
	local ang = own:EyeAngles()
	pos = pos + ang:Up() *-8 + ang:Right() * 8
		
	if !self:GetAttack() then
		
		self:SetNextPrimaryFire( CurTime() + .8 )
		own:SetAnimation( PLAYER_ATTACK1 )
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		own:EmitSound(self.Primary.Sound, 100, 100)
		self:SetIdleDelay(CurTime() +.2)
		
		local entTele = ents.Create("ut2004_translocator")
		entTele:SetAngles(Angle(0,ang.y,0))
		entTele:SetPos(pos)
		entTele:SetOwner(own)
		entTele:Spawn()
		entTele:Activate()
		local phys = entTele:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ang:Forward() *1170)
		end
		--self.entTele = entTele
		own:SetNWEntity("entTele", entTele)
		timer.Simple(.1, function() self:SetAttack(true) end)
	else
		local ent = own:GetNWEntity("entTele")
		--BSeekLost1
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetIdleDelay(CurTime() +.4)
		
		if IsValid(ent) and ent:Health() < 1 then self:WeaponSound("ut2004/weaponsounds/BSeekLost1.wav") return end
		
		self:SetAttack(false)
		if self:GetZoom() then
			self:TogglePuckCamera()
		end
		if ent:IsValid() then
			ent:Remove()
		end
		own:EmitSound(self.Primary.Special1, 100, 100)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if !self:GetAttack() then return end
	local own = self:GetOwner()
	
	local ent = own:GetNWEntity("entTele")
	if IsValid(ent) then
	
		local startpos = ent:GetPos()
		
		local tr = util.TraceHull({
			start = startpos,
			endpos = startpos,
			mins = own:OBBMins(),
			maxs = own:OBBMaxs(),
			filter = ent
		})
		
		local telepos = startpos

		if tr.HitWorld then
			local newpos = own:GetPos() - own:NearestPoint(tr.HitPos)
			telepos = tr.HitPos + newpos
			--telepos[3] = startpos[3]
			
			tr = util.TraceHull({
				start = telepos,
				endpos = telepos,
				mins = own:OBBMins(),
				maxs = own:OBBMaxs(),
				filter = ent
			})
			
			if tr.Hit and tr.Entity:Health() <= 0 then
				self:SetAttack(false)
				if self:GetZoom() then
					self:TogglePuckCamera()
				end
				if IsValid(ent) then
					ent:Remove()
				end
				self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
				own:EmitSound(self.Primary.Special1, 100, 100)
				--self:SetIdleDelay(CurTime() +.4)
				return
			end
		end
		
		self:CallOnClient("RenderTeleportEffects")
		
		if tr.HitNonWorld and tr.Entity != own then
			tr.Entity:TakeDamage(999, own)
		end
		
		--util.ParticleTracerEx( "ut2004_trans_tracers", own:GetPos(), ent:GetPos(), false, own:EntIndex(), 1 )
		
		own:SetPos(telepos)
		
		if self:GetZoom() then
			self:TogglePuckCamera()
		end

		ent.pickup = nil
		own:SetNWEntity("entTele", nil)
		ent:Remove()
		if self:GetZoom() then
			self:TogglePuckCamera()
		end
		own:EmitSound(self.Primary.Special2, 100, 100)
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
		self:SetIdleDelay(CurTime() +.3)
		self:SetAttack(false)
		self:TakeAmmo()
		self.ReturnAmmoTime = CurTime() + 1.5
		self:SetIdleDelay(CurTime() +.4)
		
		if ent:Health() < 1 then
			own:Kill()
		end
	end
end

function SWEP:CanHolster()
	return (!self.cantholster or self.cantholster <= CurTime())
end

function SWEP:RenderTeleportEffects()
	local own = self:GetOwner()
	if !IsValid(own) then return end
	local ent = own:GetNWEntity("entTele")
	
	local glow = CreateParticleSystem(own, "ut2004_trans_glow", PATTACH_POINT_FOLLOW, 3)
	glow:SetControlPoint(1, own:GetPlayerColor())
	glow:StartEmission()
	
	if !IsValid(ent) then return end
	
	local tracers = CreateParticleSystem(own, "ut2004_trans_tracers", PATTACH_ABSORIGIN)
	tracers:SetControlPoint(0, own:GetPos())
	tracers:SetControlPoint(1, ent:GetPos())
	tracers:SetControlPoint(2, own:GetPlayerColor())
	tracers:StartEmission()
	
	own:SetNWBool("Teleported", true)
	timer.Simple(1, function() 
		if IsValid(own) then
			own:SetNWBool("Teleported", false)
		end
	end)
end

function SWEP:SpecialThink()
	local own = self:GetOwner()
	local ent = own:GetNWEntity("entTele")
	if self:GetAttack() and ent and !IsValid(ent) then
		self:SetAttack(false)
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
	
	if SERVER and self:Ammo1() < 6 and CurTime() > self.ReturnAmmoTime then
		own:GiveAmmo(1, self.Primary.Ammo, true)
		self.ReturnAmmoTime = CurTime() + 1.5
	end
	
	if CLIENT then
		if IsValid(ent) and self:GetZoom() then
				ent:SetRenderAngles(own:EyeAngles())
			else
				ent:SetRenderAngles(Angle(0,0,0))
		end
		self:UpdateBonePositions(own:GetViewModel())
	end
	
	if own:KeyPressed(IN_ZOOM) then
		self:TogglePuckCamera()
	end
end

local lastpos = 0
local gunpos = Vector()

function SWEP:UpdateBonePositions(vm)
	--if self:GetHolstering() then return end
	--if !vm then vm = self:GetOwner():GetViewModel() end
	
	local puck = vm:LookupBone("Object03")
	--print(barrels, gear)
	if !puck then return end
	local speed = 4
	local attack = lastpos+1
	lastpos = Lerp(FrameTime()*40, lastpos, attack)
	local rotate = (attack*speed) %360
	vm:ManipulateBoneAngles(puck, Angle(0,rotate,0))
	if self:GetAttack() then
		vm:ManipulateBonePosition(puck, Vector(0,0,-32))
	else
		vm:ManipulateBonePosition(puck, Vector(0,0,0))
	end
end

function SWEP:TogglePuckCamera()
	local own = self:GetOwner()
	if SERVER then
		if self:GetZoom() then
			own:SetViewEntity(own)
			self:SetZoom(false)
		else
			if IsValid(own:GetNWEntity("entTele")) then
				own:SetViewEntity(own:GetNWEntity("entTele"))
				self:SetZoom(true)
			end
		end
	end
end

function SWEP:OnRemove()
	if game.SinglePlayer() then
		self:CallOnClient("ResetBonePositions")
	else
		if CLIENT and IsValid(self:GetOwner()) then
			self:ResetBonePositions()
		end
	end
	if CLIENT then return end
		
	local owner = self:GetOwner()
	if owner:IsValid() and owner:IsPlayer() and self:GetAttack() then
		self:SetAttack(false)
		if IsValid(owner:GetNWEntity("entTele")) then
			owner:GetNWEntity("entTele"):Remove()
		end
		if self:GetZoom() then
			self:TogglePuckCamera()
		end
	end
	
end

function SWEP:SpecialHolster()
	if self:GetZoom() then
		self:TogglePuckCamera()
	end
end

if CLIENT then

local Edge = surface.GetTextureID("vgui/ut2004/TranslocatorCorner")
local Interlace = surface.GetTextureID("vgui/ut2004/TranslocatorInterlace")
local static = surface.GetTextureID("vgui/ut2004/static_a")

function SWEP:DrawHUD()
	local x, y = ScrW() * 0.5, ScrH() * 0.5
	local ent = self:GetOwner():GetNWEntity("entTele")
	
	--if self:GetNWBool("DrawReticle") then
		
		surface.SetDrawColor(255, 255, 255, 255)
		
		if IsValid(ent) and self:GetZoom() then
			
			if ent:Health() < 1 then
				surface.SetTexture(static)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				return
			end
			
			surface.SetTexture(Interlace)
			surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, 1, 6 )
			
			surface.SetTexture(Edge)
			surface.DrawTexturedRect(0, 0, x, y) --Top Left
			surface.DrawTexturedRectUV( x, 0, x, y, 1, 0, 0, 1 ) --Top Right
			surface.DrawTexturedRectUV( 0, y, x, y, 0, 1, 1, 0 ) --Bottom Left
			surface.DrawTexturedRectUV( x, y, x, y, 1, 1, 0, 0 ) --Bottom Right
		end
	--end
	
end

end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/weapons/v_translocator.mdl"
SWEP.WorldModel			= "models/ut2004/weapons/w_translocator.mdl"

SWEP.DeploySound 		= Sound("ut2004/weaponsounds/translocator_change.wav")

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/BTranslocatorFire.wav")
SWEP.Primary.Special1		= Sound("ut2004/weaponsounds/BTranslocatorModuleRegeneration.wav")
SWEP.Primary.Special2		= Sound("ut2004/weaponsounds/BWeaponSpawn1.wav")
SWEP.Primary.Delay			= .3
SWEP.Primary.Automatic	= false
SWEP.Primary.Clip1 			= -1
SWEP.Primary.DefaultClip 	= 6
SWEP.Primary.Ammo			= "ammo_translocator"

SWEP.NoOnRemoveCallOnHolster = true

SWEP.Secondary.Delay		= .1
SWEP.Secondary.Automatic	= false
