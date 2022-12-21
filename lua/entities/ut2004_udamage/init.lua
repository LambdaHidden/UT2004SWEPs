--AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PDuration = 27
ENT.model = "models/ut2004/e_pickups/general/udamage.mdl"

util.AddNetworkString("UT2K4UDamageMaterial")

function ENT:StartTouch(ent)
	
end
function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self:GetAvailable() and !ent.UT2K4UDamage then
		self:SetAvailable(false)
		self:DrawShadow(false)
		--self:SetNoDraw(true)
		self.ReEnabled = CurTime() + 90 --109
		
		ent.UT2K4UDamage = true
		ent.UT2K4UDamageTime = CurTime() + self.PDuration
		ent:EmitSound("ut2004/pickupsounds/UDamagePickup.wav", 500, 100)
		
		ent:SetNWFloat("ut2004itempickup", CurTime())
		
		net.Start("UT2K4UDamageMaterial")
		net.WriteBool(true)
		net.WriteFloat(CurTime() + self.PDuration)
		net.Send(ent)
	end
end

hook.Add("EntityTakeDamage", "UT2K4EntityTakeDamage", function(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if attacker.UT2K4UDamage then
		dmginfo:ScaleDamage(2)
	end
end)

hook.Add("PlayerTick", "UT2K4UDamageThink", function(ply)
	if ply.UT2K4UDamage then
		local utime = ply.UT2K4UDamageTime - CurTime()
		
		if math.Round(utime, 4) == 3 then
			ply.UT2K4UDamageTimeOut = CurTime()
			ply:EmitSound("ut2004/pickupsounds/UDamageOut.wav")
		end
		
		if utime <= 0 then
			net.Start("UT2K4UDamageMaterial")
			net.WriteBool(false)
			net.WriteFloat(0)
			net.Send(ply)
			ply.UT2K4UDamage = nil
		end
	end
end)

hook.Add("EntityEmitSound", "UT2K4UDamageSound", function(t)
	if t.Entity:IsPlayer() and IsValid(t.Entity:GetActiveWeapon()) and !t.Entity:GetActiveWeapon():IsScripted() and t.Channel == CHAN_WEAPON and t.Entity.UT2K4UDamage then
		if t.Entity.UT2K4UDamageTime then
			t.Entity:EmitSound("Weapon_UT2004.AmpFire", 100, 100, 1, CHAN_AUTO)
		end
	end
end)

hook.Add("PlayerDeath", "UT2K4UStripDamage", function(ply)
	if ply.UT2K4UDamage then
		ply.UT2K4UDamageTime = CurTime()
	end
end)