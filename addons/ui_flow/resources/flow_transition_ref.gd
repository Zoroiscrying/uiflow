## UIFlowTransitionRef — configurable transition reference.
##
## All parameters are inline in Inspector. No separate .tres files needed.
## Supports: PRESET (with inline params), SCRIPT, ANIMATION resource.
@tool
class_name UIFlowTransitionRef extends Resource

enum Source { NONE, PRESET, SCRIPT, ANIMATION }

@export var source: Source = Source.NONE

# ── Preset configuration (inline) ────────────────────────────────────────────

@export_group("Preset")

## Which built-in transition type.
@export var preset: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE

## Animation duration in seconds.
@export_range(0.0, 2.0, 0.05) var duration: float = 0.3

## Easing function.
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

## Transition curve.
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

## Delay before animation starts.
@export_range(0.0, 2.0, 0.05) var delay: float = 0.0

# ── Script / Animation sources ───────────────────────────────────────────────

@export_group("Custom Source")

## Custom GDScript extending UIFlowTransitionBase.
@export var custom_script: GDScript = null:
	set(v):
		custom_script = v
		if v:
			source = Source.SCRIPT

## Godot Animation resource (.tres).
@export var animation: Animation = null

# ── Create instance ──────────────────────────────────────────────────────────

## Create a UIFlowTransitionBase instance from this configuration.
func create_instance() -> UIFlowTransitionBase:
	match source:
		Source.NONE:
			return UIFlowTransitionNone.new()
		Source.PRESET:
			return _create_preset()
		Source.SCRIPT:
			return _create_from_script()
		Source.ANIMATION:
			return UIFlowTransitionAnimPlayer.new(animation)
		_:
			return UIFlowTransitionNone.new()


func _create_preset() -> UIFlowTransitionBase:
	match preset:
		UIFlowTransitionType.Type.FADE:
			return UIFlowTransitionFade.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_LEFT:
			return UIFlowTransitionSlideLeft.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_RIGHT:
			return UIFlowTransitionSlideRight.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_UP:
			return UIFlowTransitionSlideUp.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SLIDE_DOWN:
			return UIFlowTransitionSlideDown.new(duration, ease_type, trans_type)
		UIFlowTransitionType.Type.SCALE:
			return UIFlowTransitionScale.new(duration, ease_type, trans_type)
		_:
			return UIFlowTransitionNone.new()


func _create_from_script() -> UIFlowTransitionBase:
	if custom_script == null:
		return UIFlowTransitionNone.new()
	var instance = custom_script.new()
	if instance is UIFlowTransitionBase:
		return instance
	push_warning("UIFlowTransitionRef: Script does not extend UIFlowTransitionBase")
	return UIFlowTransitionNone.new()
