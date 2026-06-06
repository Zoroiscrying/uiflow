## Main entry point — 3D game world with UIFlow UI overlay.
##
## The 3D world is the main scene. UI is in a CanvasLayer on top.
extends Node3D

func _ready() -> void:
	# Give UIFlow the UI root node from our scene
	var ui_root: Control = $UILayer/UIRoot
	UIFlow.set_ui_root(ui_root)
	UIFlow.push(ExampleHub, {}, UIFlowTransitionType.Type.NONE)
