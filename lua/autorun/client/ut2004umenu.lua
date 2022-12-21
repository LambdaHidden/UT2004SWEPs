local function UT2004_SettingsPanel(Panel)
	Panel:AddControl("Label", {Text = "Server"})
	Panel:AddControl("CheckBox", {Label = "Restrict Superweapons", Command = "ut2k4_restrictsuperweps"})
	Panel:AddControl("CheckBox", {Label = "Unlimited Ammo", Command = "ut2k4_unlimitedammo"})
	Panel:AddControl("CheckBox", {Label = "Weapons Stay", Command = "ut2k4_weaponsstay"})
	Panel:AddControl("Slider", {Label = "Shield Gun self-damage Force", Command = "ut2k4_shieldgun_impulse", Type = "Float", Min = 0, Max = 32})
	Panel:AddControl("Label", {Text = "Client"})
	Panel:AddControl("CheckBox", {Label = "Fire Lighting", Command = "ut2k4_lighting"})
	Panel:AddControl("CheckBox", {Label = "Shield deflection sound", Command = "ut2k4_shieldsound"})
	Panel:AddControl("Slider", {Label = "Viewmodel Bob", Command = "ut2k4_bobscale", Type = "Float", Min = 0, Max = 2})
end

local function UT2004_PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Unreal Tournament 2004", "UT2004Settings", "Settings", "", "", UT2004_SettingsPanel)
end

hook.Add("PopulateToolMenu", "UT2004_PopulateToolMenu", UT2004_PopulateToolMenu)