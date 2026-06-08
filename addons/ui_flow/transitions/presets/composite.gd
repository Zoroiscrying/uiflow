## UIFlowTransitionComposite — plays multiple effects simultaneously.
##
## Combines fade, slide, and scale into a single transition.
class_name UIFlowTransitionComposite extends UIFlowTransitionBase

var _use_fade: bool
var _use_slide: bool
var _use_scale: bool
var _duration: float
var _ease: Tween.EaseType
var _trans: Tween.TransitionType
var _slide_dir: Vector2
var _scale_from: Vector2


func _init(
	p_fade: bool, p_slide: bool, p_scale: bool,
	p_duration: float, p_ease: int, p_trans: int,
	p_slide_dir: Vector2, p_scale_from: Vector2
) -> void:
	_use_fade = p_fade
	_use_slide = p_slide
	_use_scale = p_scale
	_duration = p_duration
	_ease = p_ease as Tween.EaseType
	_trans = p_trans as Tween.TransitionType
	_slide_dir = p_slide_dir
	_scale_from = p_scale_from


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	var viewport_size: Vector2 = node.get_viewport_rect().size if node.is_inside_tree() else Vector2(1920, 1080)
	var target_pos: Vector2 = node.position
	var target_scale: Vector2 = node.scale

	# Set initial state
	if _use_fade:
		node.modulate.a = 0.0
	if _use_slide:
		node.position = target_pos + _slide_dir * viewport_size
	if _use_scale:
		node.scale = _scale_from

	node.visible = true

	# Animate to final state
	var tween: Tween = node.get_tree().create_tween().set_parallel(true)

	if _use_fade:
		tween.tween_property(node, "modulate:a", 1.0, _duration).set_ease(_ease).set_trans(_trans)
	if _use_slide:
		tween.tween_property(node, "position", target_pos, _duration).set_ease(_ease).set_trans(_trans)
	if _use_scale:
		tween.tween_property(node, "scale", target_scale, _duration).set_ease(_ease).set_trans(_trans)

	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var viewport_size: Vector2 = node.get_viewport_rect().size if node.is_inside_tree() else Vector2(1920, 1080)
	var slide_target: Vector2 = node.position + _slide_dir * viewport_size

	var tween: Tween = node.get_tree().create_tween().set_parallel(true)

	if _use_fade:
		tween.tween_property(node, "modulate:a", 0.0, _duration).set_ease(_ease).set_trans(_trans)
	if _use_slide:
		tween.tween_property(node, "position", slide_target, _duration).set_ease(_ease).set_trans(_trans)
	if _use_scale:
		tween.tween_property(node, "scale", _scale_from, _duration).set_ease(_ease).set_trans(_trans)

	if callback.is_valid():
		tween.finished.connect(callback, CONNECT_ONE_SHOT)
