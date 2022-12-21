AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.AmmoType = "9mmRound"
ENT.AmmoType2 = "SMG1_Grenade"
ENT.AmmoAmount = 60
ENT.AmmoAmount2 = 4
ENT.MaxAmmo = 200
ENT.MaxAmmo2 = 8
ENT.model = "models/ut2004/weaponstaticmesh/assaultammopickup.mdl"
ENT.SpawnPos = 0

function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self:GetAvailable() then
		local ammoCount = ent:GetAmmoCount(self.AmmoType)
		local ammoCount2 = ent:GetAmmoCount(self.AmmoType2)
		if ammoCount >= self.MaxAmmo then return end
		self:SetAvailable(false)
		self:SetNoDraw(true)
		self.ReEnabled = CurTime() + 25
		
		ent:EmitSound(self.PickupSound,85,100)
		if ammoCount < self.MaxAmmo then
			ent:SetAmmo(math.min(ammoCount + self.AmmoAmount, self.MaxAmmo), self.AmmoType)
		end
		if ammoCount2 < self.MaxAmmo2 then
			ent:SetAmmo(math.min(ammoCount2 + self.AmmoAmount2, self.MaxAmmo2), self.AmmoType2)
		end
		
		ent:SetNW2Float("ut2004itempickup", CurTime())
	end
end