AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.RespawnTime = 54
ENT.Aamount = 100
ENT.MaxArmor = 150
ENT.PickupSound = "ut2004/pickupsounds/LargeShieldPickup.wav"
ENT.model = "models/ut2004/items/powerup_supershield.mdl"

function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self.Available then
		self.Available = false
		self:SetNoDraw(true)
		self.ReEnabled = CurTime() + self.RespawnTime
		
		ent.UT2K4UShield = true
		ent:SetNWBool("UT2K4Shield", true)
		ent:EmitSound(self.PickupSound, 100, 100)
		
		ent:SetArmor(math.min(ent:Armor() + self.Aamount), self.MaxArmor)
		
		ent:SetNWFloat("ut2004itempickup", CurTime())
	end
end
/*
hook.Add("PlayerShouldTakeDamage", "UT2K4SuperShieldProtect", function(ply)
	if ply:Armor() > 100 then return false end
end)
*/
hook.Add("EntityTakeDamage", "UT2K4SuperShield", function(ply, dmginfo, took)
	if ply:IsPlayer() and took then
		local Damage = dmginfo:GetDamage()
		Damage = math.Round(Damage) -- THE REST OF THIS FUNCTION IS IN weapon_ut2004_shieldgun! Sorry, had to be done like this.
		
	end
end)