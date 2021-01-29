
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local trigger = ents.Create( "trigger_hurt" )

function ENT:Initialize()
		trigger:SetPos( self.Entity:GetPos() )
		trigger:SetOwner( self.entOwner )
		trigger:SetKeyValue( "damage", "25" )
		trigger:SetKeyValue( "damagecap", "25" )
		trigger:SetKeyValue( "damagemodel", "0" )
		trigger:SetKeyValue( "spawnflags", "1" )
		trigger:SetKeyValue( "damagetype", "0" )
		trigger:SetKeyValue( "startdisabled", "1" )
		trigger:AddEFlags(64)
		trigger:Spawn()
		trigger:SetKeyValue("mins", "-512 -512 -512")
		trigger:SetKeyValue("maxs", "512 512 512")
		trigger:SetSolid(2)
		trigger:Fire( "Enable", "", 0 )
		
	self.removedelay = CurTime() +1
end

function ENT:SetEntityOwner(ent)
	self:SetOwner(ent)
	self.entOwner = ent
end

function ENT:OnRemove()
end

function ENT:Think()
	if self.removedelay and CurTime() > self.removedelay then
		self.removedelay = nil
		trigger:Fire( "Disable", "", 0 )
		self:Remove()
	end
end
