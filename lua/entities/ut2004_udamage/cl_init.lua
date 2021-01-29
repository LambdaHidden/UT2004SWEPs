include('shared.lua')

net.Receive("UT2K4UDamageMaterial", function()
	local ply = LocalPlayer()
	LocalPlayer().UT2K4UDamage = net.ReadBool()
	LocalPlayer().UT2K4UDamageTime = net.ReadFloat()
end)