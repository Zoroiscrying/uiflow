## UIFlowDragDrop — drag and drop system for UI elements.
##
## Provides drag initiation, ghost preview, drop zone validation,
## and visual feedback for game UI drag-and-drop operations.
##
## Usage:
## [codeblock]
## # Attach to a Control to make it draggable
## var dd = UIFlowDragDrop.new()
## dd.data = {"item": item_data, "slot_index": 5}
## $ItemSlot.add_child(dd)
##
## # Attach to a Control to make it a drop target
## var target = UIFlowDropTarget.new()
## target.on_drop.connect(func(data): print("Dropped: ", data))
## $EquipmentSlot.add_child(target)
## [/codeblock]
class_name UIFlowDragDrop extends Control

## Data payload carried by the drag.
var data: Variant = null

## Texture to show during drag (optional).
var drag_icon: Texture2D = null

## Duration of long-press to start drag (seconds).
@export var long_press_duration: float = 0.3

## Is this item currently being dragged?
var is_dragging: bool = false

## Emitted when drag starts.
signal drag_started()

## Emitted when drag ends (with or without drop).
signal drag_ended()

## Emitted when dropped on a valid target.
signal dropped(target: UIFlowDropTarget)

var _press_timer: float = 0.0
var _pressing: bool = false
var _press_position: Vector2
var _last_hovered_target: UIFlowDropTarget = null

# Static reference to the current drag
static var _current_drag: UIFlowDragDrop = null
static var drag_source_index: int = -1
static var _ghost: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("UIFlowDragDrop._gui_input: button=", event.button_index, " pressed=", event.pressed, " data=", data, " size=", size, " mouse_filter=", mouse_filter)
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_pressing = true
			_press_timer = 0.0
			_press_position = event.global_position
		elif not event.pressed:
			_pressing = false
			if is_dragging:
				_end_drag(event.global_position)

	if event is InputEventMouseMotion:
		if is_dragging and _ghost:
			_ghost.global_position = event.global_position - _ghost.size / 2
		elif _pressing and not is_dragging:
			var dist: float = _press_position.distance_to(event.global_position)
			if dist > 8.0:  # Deadzone
				_start_drag()


func _process(delta: float) -> void:
	if _pressing and not is_dragging:
		_press_timer += delta
		if _press_timer >= long_press_duration:
			print("UIFlowDragDrop._process: long press reached, calling _start_drag")
			_start_drag()

	if is_dragging:
		_update_hover_highlight()


func _update_hover_highlight() -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var target := _find_drop_target(mouse_pos)

	if target == _last_hovered_target:
		return  # No change

	# Hide previous highlight
	if _last_hovered_target and is_instance_valid(_last_hovered_target):
		_last_hovered_target.hide_highlight()

	_last_hovered_target = target

	if target and is_instance_valid(target):
		if target.can_drop(data):
			# Valid target — show green highlight
			target.show_highlight()
		else:
			# Invalid target — show red highlight
			target.show_highlight()
			if target._highlight:
				target._highlight.color = Color(0.7, 0.2, 0.2, 0.3)
	else:
		# Hide all highlights when not over any target
		for node in get_tree().get_nodes_in_group("uiflow_drop_target"):
			if node is UIFlowDropTarget and is_instance_valid(node):
				node.hide_highlight()


func _start_drag() -> void:
	if _current_drag:
		print("UIFlowDragDrop._start_drag: already dragging, skip")
		return

	print("UIFlowDragDrop._start_drag: data=", data, " size=", size)
	is_dragging = true
	_current_drag = self
	drag_started.emit()

	# Create ghost
	_ghost = _create_ghost()
	if _ghost:
		get_viewport().add_child(_ghost)

	# Dim the original
	modulate.a = 0.4


func _end_drag(position: Vector2) -> void:
	print("UIFlowDragDrop._end_drag: position=", position, " data=", data)
	is_dragging = false
	modulate.a = 1.0

	# Clear any highlight
	if _last_hovered_target and is_instance_valid(_last_hovered_target):
		_last_hovered_target.hide_highlight()
	_last_hovered_target = null

	for node in get_tree().get_nodes_in_group("uiflow_drop_target"):
		if node is UIFlowDropTarget and is_instance_valid(node):
			node.hide_highlight()

	# Check for drop targets
	var target := _find_drop_target(position)
	var accepted := target != null and target.can_drop(data)
	if accepted:
		dropped.emit(target)
		target.on_drop.emit(data)
	else:
		# Drop was cancelled or rejected — restore the source slot visual.
		var source_slot := get_parent()
		if source_slot is UIFlowItemSlot:
			source_slot.set_item(data)

	drag_ended.emit()
	_current_drag = null

	# Remove ghost
	if _ghost:
		_ghost.queue_free()
		_ghost = null


func _create_ghost() -> Control:
	var ghost := TextureRect.new()
	ghost.texture = drag_icon
	ghost.custom_minimum_size = Vector2(48, 48)
	ghost.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ghost.modulate = Color(1, 1, 1, 0.7)
	ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return ghost


func _find_drop_target(position: Vector2) -> UIFlowDropTarget:
	# Use the engine's topmost hovered control so that a drop target on top
	# (e.g. an equipment slot) wins over one behind it (e.g. an inventory slot).
	var viewport := get_viewport()
	if viewport == null:
		return null
	var hovered: Control = viewport.gui_get_hovered_control()
	var node: Node = hovered
	while node != null:
		if node is UIFlowDropTarget and node.is_in_group("uiflow_drop_target"):
			return node
		# If we reached an item slot, check its children for a drop target.
		# This handles the case where the drag source (UIFlowDragDrop) is the
		# hovered control instead of the drop target.
		if node is UIFlowItemSlot:
			for child in node.get_children():
				if child is UIFlowDropTarget and child.is_in_group("uiflow_drop_target"):
					return child
		node = node.get_parent()
	return null


## Cancel the current drag.
static func cancel_drag() -> void:
	if _current_drag:
		_current_drag._end_drag(Vector2.ZERO)
