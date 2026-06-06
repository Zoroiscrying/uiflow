## Main entry point — 3D game world with UIFlow UI overlay.
extends Node3D

func _ready() -> void:
	# Wait one frame for everything to initialize
	await get_tree().process_frame
	UIFlow.push(ExampleHub, {}, UIFlowTransitionType.Type.NONE)
