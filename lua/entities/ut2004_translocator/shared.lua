if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
end

ENT.Type			= "anim"
ENT.PrintName		= "UT2004 Translocator"
ENT.Author			= "Upset"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

if SERVER then

function ENT:Initialize()
	self:SetModel("models/ut2004/weaponstaticmesh/newtranslocatorpuck.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self:PhysicsInitSphere(4.5, "metal_bouncy")
	--self:PhysicsInit(SOLID_OBB_YAW)
	--self:PhysicsInitBox(Vector(-4, -4, -0.5), Vector(4, 4, 2))
	--self:SetSolid(SOLID_VPHYSICS)
	--self:SetMoveType(MOVETYPE_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		--phys:SetMaterial("metal_bouncy")
		--phys:SetDamping(0, 128)
		phys:EnableDrag(false)
	end
	
	self:SetHealth(50)
	
	util.SpriteTrail( self, 0, self.Owner:GetPlayerColor():ToColor(), false, 32, 16, 1.5, 0.125, "trails/laser.vmt" )
	--util.SpriteTrail( self, 0, Color( 128, 128, 255 ), false, 12, 10, 1, 0.125, "trails/laser.vmt" )

	--self.sound = CreateSound(self, "ut2004/weaponsounds/BTranslocatorHoverModule.wav")
	self.sound = CreateSound(self, "ut2004/weaponsounds/misc/redeemer_flight.wav")
	self.sound:SetSoundLevel(60)
	self.sound:Play()
	self.sound:ChangePitch( 200 )
end

function ENT:OnRemove()
	if self.sound then self.sound:Stop() end
end
/*
function ENT:PhysicsUpdate(phys)
	if !IsValid(phys) then return end -- Until i can figure out how to not nullify the puck's velocity, this function will have to stay commented.
	
	if IsValid(self.Owner) and self.Owner:GetViewEntity() == self then
		self:SetAngles(self.Owner:EyeAngles())
		--print(self:GetVelocity(), phys:GetVelocity())
	else
		self:SetAngles(Angle(0,0,0))
	end
	
end
*/
function ENT:PhysicsCollide(data,phys)
	if data.Speed > 256 then
		self:EmitSound("ut2004/weaponsounds/baseguntech/BGrenfloor1.wav")
	end
	
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	if data.Speed > 128 then
		local NewVelocity = phys:GetVelocity()
		NewVelocity:Normalize()

		LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

		local TargetVelocity = NewVelocity * LastSpeed * 0.5

		phys:SetVelocity( TargetVelocity )
	else
		phys:SetVelocity(Vector(0,0,0))
	end
end

function ENT:Think()	
	if IsValid(self.Owner) and self.Owner:Alive() and self.Owner:GetPos():DistToSqr(self:GetPos()) < 400 and self.Owner:Crouching() and self:GetVelocity():LengthSqr() < 400 then
		--self.Owner:EmitSound("items/ut99/AmmoPick.wav")
		self.Owner:SetViewEntity(self.Owner)
		self:Remove()
	end
end

function ENT:OnTakeDamage(dmginfo)
	
	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if self:Health() < 0 then
		self.sound:Stop()
	end
	local phys = self:GetPhysicsObject()
	local force = dmginfo:GetDamageForce() *0.125
	force[3] = force[3] * -2
	if phys:IsValid() then
		phys:ApplyForceCenter(force)
	end
end

end

local var = false
local mat = Material("ut2004/xgameshaders/playershaders/PlayerTeleOverlay")
hook.Add("PostPlayerDraw", "UTTeleGlow", function(ply)
	if ply:GetNW2Float("Teleported") > CurTime() then
		if var then return end
		local plycol = ply:GetPlayerColor()
		render.MaterialOverride(mat)
		render.SetColorModulation(plycol[1], plycol[2], plycol[3])
		var = true
		ply:DrawModel()
		render.MaterialOverride(0)
		render.SetColorModulation(1,1,1)
		var = false
	end
end)