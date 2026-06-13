## SurvivorsEventBus — game-wide decoupled communication.
extends UIFlowEventBus

signal enemy_killed(enemy_name: String, xp: int, gold: int)
signal xp_gained(amount: float)
signal level_up(new_level: int)
signal wave_started(wave: int)
signal wave_ended(wave: int)
signal gold_changed(amount: int)
signal weapon_acquired(weapon: WeaponData)
