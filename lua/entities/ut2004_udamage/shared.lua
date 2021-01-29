ENT.Type = "anim"
ENT.Base = "ut2004_powerup_base"
ENT.PrintName = "Double Damage"
ENT.Category = "Unreal Tournament 2004"
ENT.Author = "Upset"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Spawnable = true
ENT.AdminOnly = true

local var = false

hook.Add("PostDrawViewModel", "UT2K4UDamageTexture", function(vm, ply, wep)
	if ply.UT2K4UDamage then
		--render.MaterialOverride( "ut2004/items/UDamage_overlay" )
		if var then return end
		vm:SetMaterial("ut2004/items/UDamage_overlay")
		var = true
		vm:DrawModel()
		vm:SetMaterial("")
		var = false
	end
end)