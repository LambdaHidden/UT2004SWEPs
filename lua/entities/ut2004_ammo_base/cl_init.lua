include('shared.lua')
--include('init.lua')

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Available" )
end

function ENT:Draw()
	if self:GetAvailable() then
		self:DrawModel()
	end
end