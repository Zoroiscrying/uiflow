## Main entry point — 3D game world with UIFlow UI overlay.
extends Node3D

func _ready() -> void:
	await get_tree().process_frame
	UIFlow.push(MainHUD, {}, UIFlowTransitionType.Type.NONE)
