## Generate all transition preset .tres files.
## Run this script from the editor (Tools → Execute Script) or headless.
@tool
extends EditorScript

const PRESETS_DIR := "res://addons/ui_flow/transitions/presets/"

func _run() -> void:
	if not DirAccess.dir_exists_absolute(PRESETS_DIR):
		DirAccess.make_dir_recursive_absolute(PRESETS_DIR)

	# Fade variants
	_save("fade_fast", _make_ref(_make_fade(0.15)))
	_save("fade_normal", _make_ref(_make_fade(0.3)))
	_save("fade_slow", _make_ref(_make_fade(0.6)))
	_save("fade_ease_in", _make_ref(_make_fade(0.3, Tween.EASE_IN)))
	_save("fade_ease_out", _make_ref(_make_fade(0.3, Tween.EASE_OUT)))

	# Slide variants
	_save("slide_left", _make_ref(_make_slide(UIFlowSlideEffect.Direction.LEFT)))
	_save("slide_right", _make_ref(_make_slide(UIFlowSlideEffect.Direction.RIGHT)))
	_save("slide_up", _make_ref(_make_slide(UIFlowSlideEffect.Direction.UP)))
	_save("slide_down", _make_ref(_make_slide(UIFlowSlideEffect.Direction.DOWN)))
	_save("slide_left_fast", _make_ref(_make_slide(UIFlowSlideEffect.Direction.LEFT, 0.2)))
	_save("slide_right_fast", _make_ref(_make_slide(UIFlowSlideEffect.Direction.RIGHT, 0.2)))

	# Scale variants
	_save("scale_pop", _make_ref(_make_scale(Vector2.ZERO, Vector2.ONE, 0.3, Tween.EASE_OUT, Tween.TRANS_BACK)))
	_save("scale_shrink", _make_ref(_make_scale(Vector2(1.2, 1.2), Vector2.ONE, 0.25)))
	_save("scale_bounce", _make_ref(_make_scale(Vector2.ZERO, Vector2.ONE, 0.4, Tween.EASE_OUT, Tween.TRANS_ELASTIC)))
	_save("scale_fast", _make_ref(_make_scale(Vector2.ZERO, Vector2.ONE, 0.15)))

	# Slide + Fade combinations
	_save("slide_left_fade", _make_composite([
		_make_fade(0.25),
		_make_slide(UIFlowSlideEffect.Direction.LEFT, 0.3),
	]))
	_save("slide_right_fade", _make_composite([
		_make_fade(0.25),
		_make_slide(UIFlowSlideEffect.Direction.RIGHT, 0.3),
	]))
	_save("slide_up_fade", _make_composite([
		_make_fade(0.25),
		_make_slide(UIFlowSlideEffect.Direction.UP, 0.3),
	]))
	_save("slide_down_fade", _make_composite([
		_make_fade(0.25),
		_make_slide(UIFlowSlideEffect.Direction.DOWN, 0.3),
	]))

	# Scale + Fade combinations
	_save("scale_fade", _make_composite([
		_make_fade(0.25),
		_make_scale(Vector2.ZERO, Vector2.ONE, 0.3),
	]))
	_save("scale_pop_fade", _make_composite([
		_make_fade(0.2),
		_make_scale(Vector2.ZERO, Vector2.ONE, 0.3, Tween.EASE_OUT, Tween.TRANS_BACK),
	]))

	# Sequenced effects
	_save("fade_then_scale", _make_sequence([
		_make_fade(0.2),
		_make_scale(Vector2(0.8, 0.8), Vector2.ONE, 0.25, Tween.EASE_OUT, Tween.TRANS_BACK),
	]))
	_save("scale_then_fade", _make_sequence([
		_make_scale(Vector2.ZERO, Vector2(0.5, 0.5), 0.15),
		_make_scale(Vector2(0.5, 0.5), Vector2.ONE, 0.2, Tween.EASE_OUT, Tween.TRANS_BACK),
	]))
	_save("slide_then_fade", _make_sequence([
		_make_slide(UIFlowSlideEffect.Direction.LEFT, 0.2),
		_make_fade(0.15),
	]))

	# Special effects
	_save("bounce_in", _make_ref(_make_scale(Vector2.ZERO, Vector2.ONE, 0.5, Tween.EASE_OUT, Tween.TRANS_ELASTIC)))
	_save("zoom_in", _make_ref(_make_scale(Vector2(3, 3), Vector2.ONE, 0.3, Tween.EASE_OUT)))
	_save("flip_in", _make_composite([
		_make_fade(0.3),
		_make_scale(Vector2(0, 1), Vector2.ONE, 0.3, Tween.EASE_OUT, Tween.TRANS_BACK),
	]))

	print("UIFlow: Generated %d transition presets in %s" % [30, PRESETS_DIR])


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


func _make_composite(effects: Array) -> UIFlowTransitionRef:
	var composite := UIFlowCompositeEffect.new()
	composite.effects = effects
	var ref := UIFlowTransitionRef.new()
	ref.enter_effect = composite
	ref.exit_effect = composite
	return ref


func _make_sequence(effects: Array) -> UIFlowTransitionRef:
	var seq := UIFlowSequencedEffect.new()
	seq.effects = effects
	var ref := UIFlowTransitionRef.new()
	ref.enter_effect = seq
	# Exit: reverse fade
	var exit_fade := UIFlowFadeEffect.new()
	exit_fade.duration = 0.2
	ref.exit_effect = exit_fade
	return ref


func _make_ref(effect: UIFlowTransitionEffect) -> UIFlowTransitionRef:
	var ref := UIFlowTransitionRef.new()
	ref.enter_effect = effect
	ref.exit_effect = effect
	return ref


func _save(name: String, ref: UIFlowTransitionRef) -> void:
	var path := PRESETS_DIR + name + ".tres"
	var err := ResourceSaver.save(ref, path)
	if err != OK:
		push_warning("UIFlow: Failed to save preset %s: %s" % [name, err])
