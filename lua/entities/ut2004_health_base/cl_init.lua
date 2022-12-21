include('shared.lua')
--include('init.lua')

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Available" )
end

function ENT:Initialize()
	self.Rotate = 0
	self.RotateTime = CurTime()
end

function ENT:Draw()
	if self:GetAvailable() then
		self:DrawModel()
	end
	
	self.Rotate = (CurTime() - self.RotateTime)*160 %360
	self:SetAngles(Angle(0,-self.Rotate,0))
end