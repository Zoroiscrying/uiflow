## Main entry point — 3D game world with UIFlow UI overlay.
##
## Demonstrates UIFlow working seamlessly with a real 3D scene.
## The 3D world runs continuously while UI navigates on top.
extends Control

func _ready() -> void:
	UIFlow.push(ExampleHub, {}, UIFlowTransitionType.Type.NONE)
