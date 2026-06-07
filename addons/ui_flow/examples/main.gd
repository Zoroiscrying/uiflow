## Main entry point — 3D game world with UIFlow UI.
##
## MainHUD is always visible (never popped).
## Esc opens Pause menu.
## Interactive 3D objects open Shop/Dialog pages.
extends Node3D

func _ready() -> void:
	await get_tree().process_frame
	# MainHUD is always the bottom layer, never popped
	UIFlow.push(MainHUD, {})
