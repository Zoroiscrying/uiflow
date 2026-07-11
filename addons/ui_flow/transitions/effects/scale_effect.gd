@tool
## Scale effect — animates node scale only.
class_name UIFlowScaleEffect extends UIFlowTransitionEffect

## Scale when the page is visible (enter target, exit start).
@export var hidden_scale: Vector2 = Vector2.ZERO

## Scale when the page is hidden (enter start, exit target).
@export var visible_scale: Vector2 = Vector2.ONE


func _init() -> void:
	starts_hidden = true


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	node.visible = true
	node.modulate.a = 1.0
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
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "scale", hidden_scale, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)
