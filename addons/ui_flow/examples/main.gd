## Main entry point — 3D game world with UIFlow UI overlay.
##
## The 3D world is the main scene. UIFlow UI renders on top via CanvasLayer.
extends Node3D

func _ready() -> void:
	UIFlow.push(ExampleHub, {}, UIFlowTransitionType.Type.NONE)
