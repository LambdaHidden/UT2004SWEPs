AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.RespawnTime = 27
ENT.Hsound = "ut2004/pickupsounds/HealthPack.wav"
ENT.Hamount = 20
ENT.MaxHealth = 100
ENT.model = "models/ut2004/e_pickups/health/midhealth.mdl"

function ENT:StartTouch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self:GetAvailable() and ent:Health() < self.MaxHealth then
		self:SetAvailable(false)
		--self:SetNoDraw(true)
		self.ReEnabled = CurTime() + self.RespawnTime
		
		ent:EmitSound(self.Hsound,85,100)
		ent:SetHealth(math.min(ent:Health() + self.Hamount, self.MaxHealth))
		
		ent:SetNWFloat("ut2004itempickup", CurTime())
	end
end