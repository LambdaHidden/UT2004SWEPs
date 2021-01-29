include('shared.lua')

hook.Add("PostPlayerDraw", "UT2K4UShieldBeltShell", function(ply)
	local iIndex = ply:EntIndex()
	hook.Add("RenderScreenspaceEffects", "UT2K4UShieldPlayerOverlay" .. iIndex, function()
		if IsValid(ply) and ply:GetNWBool("UT2K4UShield") then
			cam.Start3D(EyePos(), EyeAngles())
				if util.IsValidModel(ply:GetModel()) then
					render.MaterialOverride(Material("models/ushader_yellow"))
					ply:DrawModel()
					render.MaterialOverride(0)
				end
			cam.End3D()
		end
	end)
end)