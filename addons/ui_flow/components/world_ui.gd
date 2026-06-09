## UIFlowWorldUI — projects a UI element to follow a 3D node on screen.
##
## Attach to a Control node. Sets its target to any Node3D.
## The Control will follow the 3D node's position on screen.
##
## Usage:
## [codeblock]
## var world_ui = UIFlowWorldUI.new()
## world_ui.target = enemy_node
## world_ui.offset = Vector2(0, -50)  # Above the enemy
## $CanvasLayer.add_child(world_ui)
## [/codeblock]
class_name UIFlowWorldUI extends Control

## The 3D node to follow.
@export var target: Node3D

## Screen offset from the projected position.
@export var offset: Vector2 = Vector2.ZERO

## Z-offset added to the 3D position (e.g., above the node's head).
@export var world_offset: Vector3 = Vector3.ZERO

## Clamp to screen bounds.
@export var clamp_to_screen: bool = true

## Padding from screen edges when clamping.
@export var screen_padding: Vector2 = Vector2(16, 16)

## Smooth follow speed (0 = instant, higher = smoother).
@export_range(0.0, 1.0, 0.05) var smooth_speed: float = 0.0

## Hide when target is behind camera.
@export var hide_behind_camera: bool = true

var _target_position: Vector2


func _process(_delta: float) -> void:
	if target == null or not is_instance_valid(target):
		visible = false
		return

	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	var world_pos: Vector3 = target.global_position + world_offset
	var screen_pos := camera.unproject_position(world_pos)

	# Check if behind camera
	var cam_transform := camera.global_transform
	var to_target := world_pos - cam_transform.origin
	var dot := cam_transform.basis.z.dot(to_target)
	if dot > 0:
		# Behind camera
		if hide_behind_camera:
			visible = false
		return

	visible = true
	screen_pos += offset

	# Clamp to screen
	if clamp_to_screen:
		var vp_size: Vector2 = get_viewport_rect().size
		screen_pos.x = clampf(screen_pos.x, screen_padding.x, vp_size.x - screen_padding.x)
		screen_pos.y = clampf(screen_pos.y, screen_padding.y, vp_size.y - screen_padding.y)

	# Smooth follow
	if smooth_speed > 0:
		_target_position = screen_pos
		global_position = global_position.lerp(_target_position, 1.0 - smooth_speed)
	else:
		global_position = screen_pos
