## UIFlowTransitionRef — configurable transition with composable effects.
##
## All parameters are inline in Inspector. No separate .tres files needed.
## Supports combining multiple effects (fade + slide + scale).
@tool
class_name UIFlowTransitionRef extends Resource

enum Source { NONE, PRESET, SCRIPT, ANIMATION }

@export var source: Source = Source.NONE

# ── Effect toggles (combine freely) ─────────────────────────────────────────

@export_group("Effects")

## Enable fade (opacity) animation.
@export var use_fade: bool = true

## Enable slide animation.
@export var use_slide: bool = false

## Enable scale animation.
@export var use_scale: bool = false

# ── Timing ──────────────────────────────────────────────────────────────────

@export_group("Timing")

## Animation duration in seconds.
@export_range(0.0, 2.0, 0.05) var duration: float = 0.3

## Easing function.
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

## Transition curve.
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

## Delay before animation starts.
@export_range(0.0, 2.0, 0.05) var delay: float = 0.0

# ── Slide configuration ─────────────────────────────────────────────────────

@export_group("Slide")

## Slide direction.
@export var slide_direction: SlideDir = SlideDir.LEFT

enum SlideDir { LEFT, RIGHT, UP, DOWN }

# ── Scale configuration ─────────────────────────────────────────────────────

@export_group("Scale")

## Scale start value (enter) or end value (exit).
@export var scale_from: Vector2 = Vector2.ZERO

# ── Preset quick-fill ───────────────────────────────────────────────────────

@export_group("Preset")

## Fill all settings from a built-in preset type.
@export var preset: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE:
	set(v):
		_apply_preset(v)

## Apply preset and return to NONE (one-shot).
@export var apply_preset: bool = false:
	set(v):
		if v:
			_apply_preset(preset)

# ── Custom source ───────────────────────────────────────────────────────────

@export_group("Custom Source")

## Custom GDScript extending UIFlowTransitionBase.
@export var custom_script: GDScript = null

## Godot Animation resource (.tres).
@export var animation: Animation = null

# ── Create instance ──────────────────────────────────────────────────────────

## Create a UIFlowTransitionBase instance from this configuration.
func create_instance() -> UIFlowTransitionBase:
	match source:
		Source.NONE:
			return UIFlowTransitionNone.new()
		Source.PRESET:
			return _create_composite()
		Source.SCRIPT:
			return _create_from_script()
		Source.ANIMATION:
			return UIFlowTransitionAnimPlayer.new(animation)
		_:
			return UIFlowTransitionNone.new()


func _create_composite() -> UIFlowTransitionBase:
	# Single effect — use existing preset classes for compatibility
	if use_fade and not use_slide and not use_scale:
		return UIFlowTransitionFade.new(duration, ease_type, trans_type)
	if use_slide and not use_fade and not use_scale:
		return _create_slide()
	if use_scale and not use_fade and not use_slide:
		return UIFlowTransitionScale.new(duration, ease_type, trans_type)

	# Multiple effects — create composite
	var CompositeClass = preload("res://addons/ui_flow/transitions/presets/composite.gd")
	return CompositeClass.new(
		use_fade, use_slide, use_scale,
		duration, ease_type, trans_type,
		_get_slide_target(), scale_from
	)


func _create_slide() -> UIFlowTransitionBase:
	match slide_direction:
		SlideDir.LEFT: return UIFlowTransitionSlideLeft.new(duration, ease_type, trans_type)
		SlideDir.RIGHT: return UIFlowTransitionSlideRight.new(duration, ease_type, trans_type)
		SlideDir.UP: return UIFlowTransitionSlideUp.new(duration, ease_type, trans_type)
		SlideDir.DOWN: return UIFlowTransitionSlideDown.new(duration, ease_type, trans_type)
	return UIFlowTransitionSlideLeft.new(duration, ease_type, trans_type)


func _get_slide_target() -> Vector2:
	match slide_direction:
		SlideDir.LEFT: return Vector2(-1, 0)
		SlideDir.RIGHT: return Vector2(1, 0)
		SlideDir.UP: return Vector2(0, -1)
		SlideDir.DOWN: return Vector2(0, 1)
	return Vector2(-1, 0)


func _create_from_script() -> UIFlowTransitionBase:
	if custom_script == null:
		return UIFlowTransitionNone.new()
	var instance = custom_script.new()
	if instance is UIFlowTransitionBase:
		return instance
	push_warning("UIFlowTransitionRef: Script does not extend UIFlowTransitionBase")
	return UIFlowTransitionNone.new()


func _apply_preset(type: UIFlowTransitionType.Type) -> void:
	source = Source.PRESET
	duration = 0.3
	ease_type = Tween.EASE_IN_OUT
	trans_type = Tween.TRANS_LINEAR
	use_fade = false
	use_slide = false
	use_scale = false

	match type:
		UIFlowTransitionType.Type.FADE:
			use_fade = true
		UIFlowTransitionType.Type.SLIDE_LEFT:
			use_slide = true
			slide_direction = SlideDir.LEFT
			ease_type = Tween.EASE_OUT
			trans_type = Tween.TRANS_BACK
		UIFlowTransitionType.Type.SLIDE_RIGHT:
			use_slide = true
			slide_direction = SlideDir.RIGHT
			ease_type = Tween.EASE_OUT
			trans_type = Tween.TRANS_BACK
		UIFlowTransitionType.Type.SLIDE_UP:
			use_slide = true
			slide_direction = SlideDir.UP
			ease_type = Tween.EASE_OUT
			trans_type = Tween.TRANS_BACK
		UIFlowTransitionType.Type.SLIDE_DOWN:
			use_slide = true
			slide_direction = SlideDir.DOWN
			ease_type = Tween.EASE_OUT
			trans_type = Tween.TRANS_BACK
		UIFlowTransitionType.Type.SCALE:
			use_scale = true
			scale_from = Vector2.ZERO
			ease_type = Tween.EASE_OUT
			trans_type = Tween.TRANS_ELASTIC
