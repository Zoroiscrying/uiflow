## Fade effect — animates node opacity only.
@tool
class_name UIFlowFadeEffect extends UIFlowTransitionEffect

## Target opacity for enter animation.
@export var to_alpha: float = 1.0

## Start opacity (used when from_current=false).
@export var from_alpha: float = 0.0


func _init() -> void:
	starts_hidden = true


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	node.visible = true
	if not from_current:
		node.modulate.a = from_alpha
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "modulate:a", to_alpha, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.modulate.a = to_alpha
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "modulate:a", from_alpha, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)
