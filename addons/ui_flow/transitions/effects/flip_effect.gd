@tool
## Flip effect — animates node scale to simulate a card-flip.
class_name UIFlowFlipEffect extends UIFlowTransitionEffect

## Axis around which the flip is performed.
enum FlipAxis { HORIZONTAL, VERTICAL }

## Scale when the page is hidden (enter start, exit target).
@export var hidden_scale: Vector2 = Vector2(0.0, 1.0)

## Scale when the page is visible (enter target, exit start).
@export var visible_scale: Vector2 = Vector2.ONE

## Axis around which the flip is performed.
@export var flip_axis: FlipAxis = FlipAxis.HORIZONTAL:
	set(value):
		flip_axis = value
		_apply_axis()


func _init() -> void:
	starts_hidden = true
	_apply_axis()


## Updates hidden_scale based on the current flip_axis.
func _apply_axis() -> void:
	if flip_axis == FlipAxis.HORIZONTAL:
		hidden_scale = Vector2(0.0, 1.0)
	else:
		hidden_scale = Vector2(1.0, 0.0)


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	node.visible = true
	node.modulate.a = 1.0
	node.pivot_offset = node.size * 0.5
	if not from_current:
		node.scale = hidden_scale
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "scale", visible_scale, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.scale = visible_scale
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	node.pivot_offset = node.size * 0.5
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "scale", hidden_scale, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.scale = hidden_scale
		_on_finished(callback)
