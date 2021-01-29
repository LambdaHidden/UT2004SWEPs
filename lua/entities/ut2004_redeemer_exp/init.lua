
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:DrawShadow(false)
	self.removedelay = CurTime() +2
	self.rad1 = CurTime() + .01
	self.rad2 = CurTime() + .7
	self.rad3 = CurTime() + 1
	self.rad4 = CurTime() + 1.2
	//self.rad5 = CurTime() + 1.5
end

function ENT:Think()
	if self.rad1 and CurTime() > self.rad1 then
		self.rad1 = nil
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 256, 256 )
	end

	if self.rad2 and CurTime() > self.rad2 then
		self.rad2 = nil
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 512, 256 )
	end
	
	if self.rad3 and CurTime() > self.rad3 then
		self.rad3 = nil
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 1024, 256 )
	end
	
	if self.rad4 and CurTime() > self.rad4 then
		self.rad4 = nil
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 1536, 32 )
	end
	
	/*if self.rad5 and CurTime() > self.rad5 then
		self.rad5 = nil
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 2200, 1 )
	end*/

	if self.removedelay and CurTime() > self.removedelay then
		self.removedelay = nil
		self:Remove()
	end
end
