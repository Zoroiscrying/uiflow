## Player Character — WASD movement + mouse camera control.
## Scene structure defined in player_character.tscn.
extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.003

## Optional stats resource (used by ARPG example).
var stats: Resource = null

var _yaw: float = 0.0
var _pitch: float = -0.5

@onready var _model: Node3D = $Model
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera_arm: SpringArm3D = $CameraPivot/CameraArm


func _ready() -> void:
	add_to_group("player")
	_camera_arm.rotation.x = _pitch


func _input(event: InputEvent) -> void:
	# Right-mouse-drag → rotate camera
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_yaw -= event.relative.x * MOUSE_SENSITIVITY
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENSITIVITY, -1.2, 0.2)
		_camera_pivot.rotation.y = _yaw
		_camera_arm.rotation.x = _pitch

	# Scroll → zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera_arm.spring_length = maxf(_camera_arm.spring_length - 0.5, 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera_arm.spring_length = minf(_camera_arm.spring_length + 0.5, 15.0)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# WASD input
	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Movement relative to camera yaw
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, _yaw)

	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# Rotate model to face movement (NOT the whole CharacterBody3D)
		var target_yaw := atan2(direction.x, direction.z)
		_model.rotation.y = lerp_angle(_model.rotation.y, target_yaw, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
		velocity.z = move_toward(velocity.z, 0, SPEED * 0.2)

	move_and_slide()
