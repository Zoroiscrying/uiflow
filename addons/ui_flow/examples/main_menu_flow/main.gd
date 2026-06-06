## Main Menu Flow — demonstrates basic push/pop navigation with transitions.
##
## Flow: TitleScreen → MainMenu → Settings / Credits / Shop
extends Control

func _ready() -> void:
	UIFlow.push(TitleScreen, {}, UIFlowTransitionType.Type.NONE)
