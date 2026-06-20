## Slide effect — animates node position only.
class_name UIFlowSlideEffect extends UIFlowTransitionEffect

enum Direction { LEFT, RIGHT, UP, DOWN }

@export var direction: Direction = Direction.LEFT


func _init() -> void:
	starts_hidden = true


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	node.visible = true
	node.modulate.a = 1.0
	if not from_current:
		var viewport_size: Vector2 = node.get_viewport_rect().size
		node.position += _get_offset(viewport_size)
	var tween := _create_tween(node)
	if tween:
		# Target is the node's original position before we offset it
		var target: Vector2 = node.position if from_current else node.position - _get_offset(node.get_viewport_rect().size)
		# Recalculate: target should be where the node "should" be
		# For slide, the target is the node's design position
		# We stored the offset, so target = current - offset
		if not from_current:
			target = node.position - _get_offset(node.get_viewport_rect().size)
		else:
			target = node.position
		tween.tween_property(node, "position", target, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	var viewport_size: Vector2 = node.get_viewport_rect().size
	var target_pos: Vector2 = node.position + _get_offset(viewport_size)
	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "position", target_pos, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		_on_finished(callback)


func _get_offset(viewport_size: Vector2) -> Vector2:
	match direction:
		Direction.LEFT: return Vector2(-viewport_size.x, 0)
		Direction.RIGHT: return Vector2(viewport_size.x, 0)
		Direction.UP: return Vector2(0, -viewport_size.y)
		Direction.DOWN: return Vector2(0, viewport_size.y)
	return Vector2.ZERO
