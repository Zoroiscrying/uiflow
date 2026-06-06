## Main entry point — starts the UIFlow example hub.
##
## This scene uses UIFlow itself to navigate between examples,
## demonstrating the framework's core navigation capabilities.
extends Control

func _ready() -> void:
	UIFlow.push(ExampleHub, {}, UIFlowTransitionType.Type.NONE)
