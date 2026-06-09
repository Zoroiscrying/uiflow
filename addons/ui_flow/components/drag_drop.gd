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

# Static reference to the current drag
static var _current_drag: UIFlowDragDrop = null
static var _ghost: Control = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
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
			_start_drag()


func _start_drag() -> void:
	if _current_drag:
		return

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
	is_dragging = false
	modulate.a = 1.0

	# Check for drop targets
	var target := _find_drop_target(position)
	if target and target.can_drop(data):
		dropped.emit(target)
		target.on_drop.emit(data)

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
	var nodes := get_tree().get_nodes_in_group("uiflow_drop_target")
	for node in nodes:
		if node is UIFlowDropTarget and node is Control:
			var ctrl: Control = node
			if ctrl.get_global_rect().has_point(position):
				return node
	return null


## Cancel the current drag.
static func cancel_drag() -> void:
	if _current_drag:
		_current_drag._end_drag(Vector2.ZERO)
