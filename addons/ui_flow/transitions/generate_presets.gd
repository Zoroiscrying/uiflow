## Generate individual transition effect .tres files.
## Run this script from the editor (Tools → Execute Script) or headless.
@tool
extends EditorScript

const PRESETS_DIR := "res://addons/ui_flow/transitions/presets/"

func _run() -> void:
	if not DirAccess.dir_exists_absolute(PRESETS_DIR):
		DirAccess.make_dir_recursive_absolute(PRESETS_DIR)

	# Fade variants
	_save("fade_fast", _make_fade(0.15))
	_save("fade_normal", _make_fade(0.3))
	_save("fade_slow", _make_fade(0.6))
	_save("fade_ease_in", _make_fade(0.3, Tween.EASE_IN))
	_save("fade_ease_out", _make_fade(0.3, Tween.EASE_OUT))

	# Slide variants
	_save("slide_left", _make_slide(UIFlowSlideEffect.Direction.LEFT))
	_save("slide_right", _make_slide(UIFlowSlideEffect.Direction.RIGHT))
	_save("slide_up", _make_slide(UIFlowSlideEffect.Direction.UP))
	_save("slide_down", _make_slide(UIFlowSlideEffect.Direction.DOWN))
	_save("slide_left_fast", _make_slide(UIFlowSlideEffect.Direction.LEFT, 0.2))
	_save("slide_right_fast", _make_slide(UIFlowSlideEffect.Direction.RIGHT, 0.2))

	# Scale variants
	_save("scale_pop", _make_scale(Vector2.ZERO, Vector2.ONE, 0.3, Tween.EASE_OUT, Tween.TRANS_BACK))
	_save("scale_shrink", _make_scale(Vector2(1.2, 1.2), Vector2.ONE, 0.25))
	_save("scale_bounce", _make_scale(Vector2.ZERO, Vector2.ONE, 0.4, Tween.EASE_OUT, Tween.TRANS_ELASTIC))
	_save("scale_fast", _make_scale(Vector2.ZERO, Vector2.ONE, 0.15))

	print("UIFlow: Generated transition effect presets in %s" % PRESETS_DIR)


func _make_fade(duration: float, ease: Tween.EaseType = Tween.EASE_IN_OUT) -> UIFlowFadeEffect:
	var e := UIFlowFadeEffect.new()
	e.duration = duration
	e.ease_type = ease
	return e


func _make_slide(dir: UIFlowSlideEffect.Direction, duration: float = 0.3) -> UIFlowSlideEffect:
	var e := UIFlowSlideEffect.new()
	e.direction = dir
	e.duration = duration
	e.ease_type = Tween.EASE_OUT
	e.trans_type = Tween.TRANS_BACK
	return e


func _make_scale(from: Vector2, to: Vector2, duration: float,
	ease: Tween.EaseType = Tween.EASE_IN_OUT,
	trans: Tween.TransitionType = Tween.TRANS_LINEAR) -> UIFlowScaleEffect:
	var e := UIFlowScaleEffect.new()
	e.from_scale = from
	e.to_scale = to
	e.duration = duration
	e.ease_type = ease
	e.trans_type = trans
	return e


func _save(name: String, effect: Resource) -> void:
	var path := PRESETS_DIR + name + ".tres"
	var err := ResourceSaver.save(effect, path)
	if err != OK:
		push_warning("UIFlow: Failed to save preset %s: %s" % [name, err])
