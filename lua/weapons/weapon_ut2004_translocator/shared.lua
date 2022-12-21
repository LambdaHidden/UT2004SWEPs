

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
	self:NetworkVar("Entity", 1, "Puck")
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
		self:SetPuck(entTele) --own:SetNW2Entity("entTele", entTele)
		timer.Simple(.1, function() self:SetAttack(true) end)
	else
		local ent = self:GetPuck()--own:GetNW2Entity("entTele")
		--BSeekLost1
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetIdleDelay(CurTime() +.4)
		
		if IsValid(ent) and ent:Health() < 1 then self:WeaponSound("ut2004/weaponsounds/baseguntech/BSeekLost1.wav") return end
		
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
	
	local ent = self:GetPuck() --own:GetNW2Entity("entTele")
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
		
		self:CallOnClient("RenderTeleportEffects", ent:EntIndex())
		
		if tr.HitNonWorld and tr.Entity != own then
			tr.Entity:TakeDamage(999, own)
		end
		
		--util.ParticleTracerEx( "ut2004_trans_tracers", own:GetPos(), ent:GetPos(), false, own:EntIndex(), 1 )
		
		own:SetPos(telepos)
		
		if self:GetZoom() then
			self:TogglePuckCamera()
		end

		ent.pickup = nil
		self:SetPuck(nil) --own:SetNW2Entity("entTele", nil)
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
		self:TakeAmmo(1)
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

function SWEP:RenderTeleportEffects(puck)
	local own = self:GetOwner()
	if !IsValid(own) then return end
	
	local ent = Entity(tonumber(puck))
	
	local glow = CreateParticleSystem(own, "ut2004_trans_glow", PATTACH_POINT_FOLLOW, 3)
	glow:SetControlPoint(1, own:GetPlayerColor())
	glow:StartEmission()
	
	own:SetNW2Float("Teleported", CurTime()+1)
	
	if !IsValid(ent) then return end
	
	local tracers = CreateParticleSystem(own, "ut2004_trans_tracers", PATTACH_ABSORIGIN)
	tracers:SetControlPoint(0, own:GetPos())
	tracers:SetControlPoint(1, ent:GetPos())
	tracers:SetControlPoint(2, own:GetPlayerColor())
	tracers:StartEmission()
end

function SWEP:SpecialThink()
	local own = self:GetOwner()
	local ent = self:GetPuck() --own:GetNW2Entity("entTele")
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
			if IsValid(self:GetPuck()) then
				own:SetViewEntity(self:GetPuck())
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
	local ent = self:GetPuck()
	if owner:IsValid() and owner:IsPlayer() and self:GetAttack() then
		self:SetAttack(false)
		if IsValid(ent) then
			ent:Remove()
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

local Interlace = surface.GetTextureID("ut2004/xgameshaders/zoomfx/TransCamFB")
local static = surface.GetTextureID("ut2004/xgameshaders/zoomfx/ScreenNoiseFB")

function SWEP:DrawHUD()
	local x, y = ScrW() * 0.5, ScrH() * 0.5
	local ent = self:GetPuck() --self:GetOwner():GetNW2Entity("entTele")
	
	--if self:GetNW2Bool("DrawReticle") then
		
		surface.SetDrawColor(255, 255, 255, 128)
		
		if IsValid(ent) and self:GetZoom() then
			
			if ent:Health() <= 0 then
				surface.SetTexture(static)
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
				return
			end
			
			surface.SetTexture(Interlace)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		end
	--end
	
end

end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_ut2004_base"
SWEP.Category			= "Unreal Tournament 2004"
SWEP.Spawnable			= true

SWEP.ViewModel			= "models/ut2004/newweapons2004/newtranslauncher_1st.mdl"
SWEP.WorldModel			= "models/ut2004/newweapons2004/newtranslauncher_3rd.mdl"

SWEP.DeploySound 		= Sound("ut2004/weaponsounds/misc/translocator_change.wav")

SWEP.Primary.Sound			= Sound("ut2004/weaponsounds/basefiringsounds/BTranslocatorFire.wav")
SWEP.Primary.Special1		= Sound("ut2004/weaponsounds/baseguntech/BTranslocatorModuleRegeneration.wav")
SWEP.Primary.Special2		= Sound("ut2004/weaponsounds/baseguntech/BWeaponSpawn1.wav")
SWEP.Primary.Delay			= .3
SWEP.Primary.Automatic	= false
SWEP.Primary.Clip1 			= -1
SWEP.Primary.DefaultClip 	= 6
SWEP.Primary.Ammo			= "ammo_translocator"

SWEP.NoOnRemoveCallOnHolster = true

SWEP.Secondary.Delay		= .1
SWEP.Secondary.Automatic	= false