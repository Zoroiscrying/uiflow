## Slide effect — animates node position.
@tool
class_name UIFlowSlideEffect extends UIFlowTransitionEffect

## Slide direction.
enum Direction { LEFT, RIGHT, UP, DOWN }

## Direction to slide from (enter) or to (exit).
@export var direction: Direction = Direction.LEFT


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	var viewport_size: Vector2 = node.get_viewport_rect().size if node.is_inside_tree() else Vector2(1920, 1080)
	var target_pos: Vector2 = node.position
	var start_pos: Vector2 = target_pos + _get_offset(viewport_size)

	node.position = start_pos
	node.visible = true

	var tween := _create_tween(node)
	if tween:
		tween.tween_property(node, "position", target_pos, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.position = target_pos
		_on_finished(callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	var viewport_size: Vector2 = node.get_viewport_rect().size if node.is_inside_tree() else Vector2(1920, 1080)
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
