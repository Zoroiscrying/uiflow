@tool
## Shared element transition — moves the actual Control from the outgoing page
## into the same-named Control on the incoming page.
##
## Instead of creating a visual clone, this effect reparents the source node to
## the page container during the animation, then restores it to the original
## page (hidden) once the transition completes.
class_name UIFlowSharedElementTransition extends UIFlowTransitionEffect

## Name of the Control that exists in both pages and should be morphed.
@export var element_name: StringName = &""

## If true, the incoming page fades in while the shared element moves.
@export var fade_new_page: bool = true

## If true, the source node's size morphs to the target's size.
@export var morph_size: bool = true

## If true, the source node's rotation morphs to the target's global rotation.
@export var morph_rotation: bool = false

## If true, the source node's scale morphs to the target's global scale.
@export var morph_scale: bool = false

## If true, the source node's self_modulate morphs to the target's self_modulate.
@export var morph_modulate: bool = false

## Optional curved path. The curve is interpreted in normalized space from (0,0)
## to (1,0); x maps to the straight-line progress and y maps to the perpendicular
## offset. If left empty, the node moves in a straight line.
@export var path_curve: Curve2D = null


## Factory helper for code-driven transitions.
static func create(p_element_name: StringName, p_duration: float = 0.4) -> UIFlowSharedElementTransition:
	var effect := UIFlowSharedElementTransition.new()
	effect.element_name = p_element_name
	effect.duration = p_duration
	return effect


func _init() -> void:
	starts_hidden = true
	trans_type = Tween.TRANS_CUBIC
	ease_type = Tween.EASE_IN_OUT


## Fallback when no outgoing page is available.
func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return
	node.visible = true
	var tween := _create_tween(node)
	if tween:
		node.modulate.a = 0.0
		tween.tween_property(node, "modulate:a", 1.0, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func(): _on_finished(callback), CONNECT_ONE_SHOT)
	else:
		node.modulate.a = 1.0
		_on_finished(callback)


## Main entry used by the navigator when an outgoing page exists.
func play_enter_with_partner(from_page: Control, to_page: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(from_page) or not is_instance_valid(to_page):
		play_enter(to_page, callback)
		return

	var source := _find_element(from_page, element_name)
	var target := _find_element(to_page, element_name)
	if source == null or target == null:
		push_warning("UIFlowSharedElementTransition: element '%s' not found in both pages." % element_name)
		play_enter(to_page, callback)
		return

	to_page.visible = true
	if fade_new_page:
		to_page.modulate.a = 0.0

	# Wait one frame so the target has a valid layout rect.
	await Engine.get_main_loop().process_frame

	var source_state := _detach(source, to_page)
	target.visible = false

	var tween := _create_tween(source)
	if tween:
		_setup_morph_tweens(tween, source, target)
		if fade_new_page:
			tween.parallel().tween_property(to_page, "modulate:a", 1.0, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func():
			target.visible = true
			_restore(source, source_state, false)
			_on_finished(callback)
		, CONNECT_ONE_SHOT)
	else:
		target.visible = true
		_restore(source, source_state, false)
		_on_finished(callback)


## Entry used by the navigator when popping a page with a shared element exit effect.
func play_exit_with_partner(outgoing_page: Control, incoming_page: Control, callback: Callable = Callable()) -> void:
	if not is_instance_valid(outgoing_page) or not is_instance_valid(incoming_page):
		play_exit(outgoing_page, callback)
		return

	var source := _find_element(outgoing_page, element_name)
	var target := _find_element(incoming_page, element_name)
	if source == null or target == null:
		push_warning("UIFlowSharedElementTransition: element '%s' not found in both pages." % element_name)
		play_exit(outgoing_page, callback)
		return

	incoming_page.visible = true
	incoming_page.modulate.a = 1.0

	# Wait one frame so both elements have valid layout rects.
	await Engine.get_main_loop().process_frame

	var source_state := _detach(source, incoming_page)
	target.visible = false

	var tween := _create_tween(source)
	if tween:
		_setup_morph_tweens(tween, source, target)
		tween.parallel().tween_property(outgoing_page, "modulate:a", 0.0, duration).set_ease(ease_type).set_trans(trans_type)
		tween.finished.connect(func():
			target.visible = true
			_restore(source, source_state, false)
			outgoing_page.modulate.a = 1.0
			_on_finished(callback)
		, CONNECT_ONE_SHOT)
	else:
		target.visible = true
		_restore(source, source_state, false)
		_on_finished(callback)


func _setup_morph_tweens(tween: Tween, source: Control, target: Control) -> void:
	var from_pos := source.global_position
	var to_pos := target.global_position

	if path_curve != null:
		tween.tween_method(func(progress: float):
			source.global_position = _sample_path(from_pos, to_pos, progress)
		, 0.0, 1.0, duration).set_ease(ease_type).set_trans(trans_type)
	else:
		tween.tween_property(source, "global_position", to_pos, duration).set_ease(ease_type).set_trans(trans_type)

	if morph_size:
		tween.parallel().tween_property(source, "size", target.size, duration).set_ease(ease_type).set_trans(trans_type)
	if morph_rotation:
		var target_rotation := target.get_global_transform().get_rotation()
		tween.parallel().tween_property(source, "rotation", target_rotation, duration).set_ease(ease_type).set_trans(trans_type)
	if morph_scale:
		var target_scale := target.get_global_transform().get_scale()
		tween.parallel().tween_property(source, "scale", target_scale, duration).set_ease(ease_type).set_trans(trans_type)
	if morph_modulate:
		tween.parallel().tween_property(source, "self_modulate", target.self_modulate, duration).set_ease(ease_type).set_trans(trans_type)


func _sample_path(from_pos: Vector2, to_pos: Vector2, progress: float) -> Vector2:
	if path_curve == null:
		return from_pos.lerp(to_pos, progress)

	var point := path_curve.sample_baked(progress)
	var forward := to_pos - from_pos
	var distance := forward.length()
	if distance < 0.001:
		return to_pos
	forward = forward / distance
	var right := forward.orthogonal()
	return from_pos + forward * point.x * distance + right * point.y * distance


func _find_element(page: Control, name: StringName) -> Control:
	if page == null:
		return null
	var node := page.find_child(String(name), true, false)
	if node is Control:
		return node as Control
	return null


## Reparents [param source] to the page container while preserving its global rect.
## Returns the original state so it can be restored later.
func _detach(source: Control, page: Control) -> Dictionary:
	var state := {
		"parent": source.get_parent(),
		"index": source.get_index(),
		"visible": source.visible,
		"modulate": source.modulate,
		"self_modulate": source.self_modulate,
		"rotation": source.rotation,
		"scale": source.scale,
		"anchor_left": source.anchor_left,
		"anchor_top": source.anchor_top,
		"anchor_right": source.anchor_right,
		"anchor_bottom": source.anchor_bottom,
		"offset_left": source.offset_left,
		"offset_top": source.offset_top,
		"offset_right": source.offset_right,
		"offset_bottom": source.offset_bottom,
		"position": source.position,
		"size": source.size,
		"top_level": source.top_level,
		"z_index": source.z_index,
		"mouse_filter": source.mouse_filter,
	}

	var container := page.get_parent() as Control
	var use_top_level := true
	if container == null:
		container = page

	var global_rect := source.get_global_rect()
	state.parent.remove_child(source)
	container.add_child(source)

	source.top_level = use_top_level
	source.z_index = 1000
	source.mouse_filter = Control.MOUSE_FILTER_IGNORE
	source.set_anchors_preset(Control.PRESET_TOP_LEFT)
	source.anchor_right = 0.0
	source.anchor_bottom = 0.0
	source.global_position = global_rect.position
	source.size = global_rect.size
	source.visible = true

	return state


## Restores [param source] to its original parent and original layout state.
## [param visible] sets the final visibility of the node.
func _restore(source: Control, state: Dictionary, visible: bool) -> void:
	if not is_instance_valid(source):
		return
	var parent: Node = state.get("parent")
	if parent == null or not is_instance_valid(parent):
		return

	# Hide before reparenting/restoring layout to avoid a one-frame jump.
	source.visible = false

	var current_parent := source.get_parent()
	if current_parent != null and current_parent != parent:
		current_parent.remove_child(source)
	parent.add_child(source)
	var index: int = state.get("index", -1)
	if index >= 0 and index < parent.get_child_count():
		parent.move_child(source, index)

	source.top_level = state.top_level
	source.z_index = state.z_index
	source.mouse_filter = state.mouse_filter
	source.modulate = state.modulate
	source.self_modulate = state.self_modulate
	source.rotation = state.rotation
	source.scale = state.scale

	source.anchor_left = state.anchor_left
	source.anchor_top = state.anchor_top
	source.anchor_right = state.anchor_right
	source.anchor_bottom = state.anchor_bottom
	source.offset_left = state.offset_left
	source.offset_top = state.offset_top
	source.offset_right = state.offset_right
	source.offset_bottom = state.offset_bottom
	source.position = state.position
	source.size = state.size
	source.visible = visible
