## UIFlowTransitionRef — a reference to a transition that can be a preset, script, or animation file.
##
## Use this in Inspector to configure page enter/exit animations.
## Supports three sources:
## - PRESET: built-in transition type (FADE, SLIDE_LEFT, etc.)
## - SCRIPT: custom GDScript extending UIFlowTransitionBase
## - ANIMATION: Godot Animation resource (.tres)
@tool
class_name UIFlowTransitionRef extends Resource

## Transition source type.
enum Source {
	NONE,        ## No animation
	PRESET,      ## Built-in preset type
	SCRIPT,      ## Custom GDScript class
	ANIMATION,   ## Godot Animation resource
}

## Which source to use.
@export var source: Source = Source.NONE

## For PRESET: which built-in type.
@export var preset: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE:
	set(v):
		preset = v
		if source == Source.NONE:
			source = Source.PRESET

## For PRESET: animation duration in seconds.
@export_range(0.0, 2.0, 0.05) var duration: float = 0.3

## For SCRIPT: custom transition script (must extend UIFlowTransitionBase).
@export var script: GDScript = null:
	set(v):
		script = v
		if v:
			source = Source.SCRIPT

## For ANIMATION: Godot Animation resource.
@export var animation: Animation = null:
	set(v):
		animation = v
		if v:
			source = Source.ANIMATION

## Create a UIFlowTransitionBase instance from this reference.
func create_instance() -> UIFlowTransitionBase:
	match source:
		Source.NONE:
			return UIFlowTransitionNone.new()
		Source.PRESSET:
			return _create_preset_instance()
		Source.SCRIPT:
			return _create_script_instance()
		Source.ANIMATION:
			return _create_animation_instance()
		_:
			return UIFlowTransitionNone.new()


func _create_preset_instance() -> UIFlowTransitionBase:
	match preset:
		UIFlowTransitionType.Type.FADE:
			return UIFlowTransitionFade.new(duration)
		UIFlowTransitionType.Type.SLIDE_LEFT:
			return UIFlowTransitionSlideLeft.new(duration)
		UIFlowTransitionType.Type.SLIDE_RIGHT:
			return UIFlowTransitionSlideRight.new(duration)
		UIFlowTransitionType.Type.SLIDE_UP:
			return UIFlowTransitionSlideUp.new(duration)
		UIFlowTransitionType.Type.SLIDE_DOWN:
			return UIFlowTransitionSlideDown.new(duration)
		UIFlowTransitionType.Type.SCALE:
			return UIFlowTransitionScale.new(duration)
		_:
			return UIFlowTransitionNone.new()


func _create_script_instance() -> UIFlowTransitionBase:
	if script == null:
		return UIFlowTransitionNone.new()
	var instance = script.new()
	if instance is UIFlowTransitionBase:
		return instance
	push_warning("UIFlowTransitionRef: Script does not extend UIFlowTransitionBase")
	return UIFlowTransitionNone.new()


func _create_animation_instance() -> UIFlowTransitionBase:
	if animation == null:
		return UIFlowTransitionNone.new()
	# Create a transition that plays the Animation resource
	return UIFlowTransitionAnimPlayer.new(animation)
