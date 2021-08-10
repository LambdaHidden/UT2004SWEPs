game.AddParticles("particles/ut2004_particles.pcf")
PrecacheParticleSystem("ut2004_lightning")
PrecacheParticleSystem("ut2004_lightning_vm")
PrecacheParticleSystem("ut2004_lightning_sparks")

PrecacheParticleSystem("ut2004_bio_explode")

PrecacheParticleSystem("ut2004_link_beam")
PrecacheParticleSystem("ut2004_link_trail")

PrecacheParticleSystem("ut2004_flak_explosion")
PrecacheParticleSystem("ut2004_flak_explosion1")
PrecacheParticleSystem("ut2004_smoketrail_flak")

PrecacheParticleSystem("ut2004_smoketrail_rocket")

PrecacheParticleSystem("ut2004_smoketrail_redeemer")
PrecacheParticleSystem("ut2004_redeemer_exp")

PrecacheParticleSystem("ut2004_shockcore")
PrecacheParticleSystem("ut2004_shockcore_impact")
PrecacheParticleSystem("ut2004_shockcore_explosion")
PrecacheParticleSystem("ut2004_shock_muzzle")

PrecacheParticleSystem("ut2004_shieldgun_muzzle")
PrecacheParticleSystem("ut2004_shieldgun_charge")

PrecacheParticleSystem("ut2004_trans_tracers")
PrecacheParticleSystem("ut2004_trans_glow")

PrecacheParticleSystem("ut2004_item_spawner")
PrecacheParticleSystem("ut2004_item_respawn")

PrecacheParticleSystem("ut2004_gl_explosion")
PrecacheParticleSystem("ut2004_smoketrail_cheap")
PrecacheParticleSystem("ut2004_smoketrail_grenade")

--PrecacheParticleSystem("ut2004_smoketrail_avril")

sound.Add(
{
    name = "Weapon_UT2004.AR_Fire",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 80,
    sound = "ut2004/weaponsounds/BAssaultRifleFire.wav"
})

sound.Add(
{
    name = "Weapon_UT2004.RL_Open",
    channel = CHAN_WEAPON,
    volume = 0.4,
    soundlevel = 80,
    sound = "ut2004/weaponsounds/BRocketLauncherLoad.wav"
})

sound.Add(
{
    name = "Weapon_UT2004.FlakCannon_AmmoPickup",
    channel = CHAN_ITEM,
    volume = 0.5,
    soundlevel = 80,
    sound = "ut2004/pickupsounds/FlakAmmoPickup.wav"
})

sound.Add(
{
    name = "Weapon_UT2004.LinkDown1",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 90,
    sound = "ut2004/weaponsounds/BLinkGunBeam1.wav"
})/*
sound.Add(
{
    name = "Weapon_UT2004.LinkDown2",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 90,
    sound = "ut2004/weaponsounds/BLinkGunBeam2.wav"
})
sound.Add(
{
    name = "Weapon_UT2004.LinkDown3",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 90,
    sound = "ut2004/weaponsounds/BLinkGunBeam3.wav"
})
sound.Add(
{
    name = "Weapon_UT2004.LinkDown4",
    channel = CHAN_WEAPON,
    volume = 1.0,
    soundlevel = 90,
    sound = "ut2004/weaponsounds/BLinkGunBeam4.wav"
})
*/
sound.Add(
{
    name = "Weapon_UT2004.AmpFire",
    channel = CHAN_ITEM,
    volume = 1.0,
	level = 100,
    soundlevel = 90,
    sound = "ut2004/gamesounds/UDamageFire.wav"
})

sound.Add(
{
    name = "Weapon_UT2004.AmpOut",
    channel = CHAN_ITEM,
    volume = 1.0,
	level = 100,
    soundlevel = 90,
    sound = "ut2004/gamesounds/UDamageOut.wav"
})

sound.Add(
{
    name = "Weapon_UT2004.ParasiteMine_Walk",
    channel = CHAN_AUTO,
    volume = 1.0,
	level = 100,
    soundlevel = 90,
    sound = {
		"ut2004/onsvehiclesounds-s/SpiderMineWalk01.wav",
		"ut2004/onsvehiclesounds-s/SpiderMineWalk02.wav",
		"ut2004/onsvehiclesounds-s/SpiderMineWalk03.wav"
	}
})

game.AddAmmoType( { name = "ammo_bio", dmgtype = DMG_BULLET } )
game.AddAmmoType( { name = "ammo_pulse_cell", dmgtype = DMG_BULLET } )
game.AddAmmoType( { name = "ammo_flak_shells", dmgtype = DMG_BULLET } )
game.AddAmmoType( { name = "ammo_rifle", dmgtype = DMG_BULLET } )
game.AddAmmoType( { name = "ammo_asmd", dmgtype = DMG_SHOCK } )
game.AddAmmoType( { name = "ammo_translocator", dmgtype = DMG_BLUNT } )
game.AddAmmoType( { name = "ammo_redeemer", dmgtype = DMG_BLAST } )
game.AddAmmoType( { name = "ammo_avril_rockets", dmgtype = DMG_BLAST } )
game.AddAmmoType( { name = "ammo_parasite_mines", dmgtype = DMG_BLAST } )
