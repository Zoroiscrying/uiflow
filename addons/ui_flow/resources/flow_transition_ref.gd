## UIFlowTransitionRef — a transition configuration that holds enter/exit effects.
##
## Each effect is a UIFlowTransitionEffect Resource (fade, slide, scale, composite, or custom).
## Configure in Inspector by creating inline effect Resources.
@tool
class_name UIFlowTransitionRef extends Resource

const _EffectBase = preload("res://addons/ui_flow/transitions/effect_base.gd")
const _BridgeClass = preload("res://addons/ui_flow/transitions/transition_effect_bridge.gd")

## Effect played when the page is pushed.
@export var enter_effect: Resource = null

## Effect played when the page is popped.
@export var exit_effect: Resource = null

## Get the enter effect as UIFlowTransitionEffect.
func get_enter_effect():
	if enter_effect is _EffectBase:
		return enter_effect
	return null

## Get the exit effect as UIFlowTransitionEffect.
func get_exit_effect():
	if exit_effect is _EffectBase:
		return exit_effect
	return null

## Create a UIFlowTransitionBase instance from this reference.
func create_instance():
	return _BridgeClass.new(get_enter_effect(), get_exit_effect())
