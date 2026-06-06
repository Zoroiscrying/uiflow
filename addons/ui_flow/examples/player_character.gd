## Player Character — WASD movement, mouse controls camera independently.
## Character rotation follows movement direction, camera follows mouse.
extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.003

var _yaw: float = 0.0
var _pitch: float = -0.5
var _camera_arm: SpringArm3D


func _ready() -> void:
	# Collision shape
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	collision.shape = capsule
	collision.position = Vector3(0, 0.8, 0)
	add_child(collision)

	# Visual mesh (capsule)
	var mesh := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.6
	mesh.mesh = capsule_mesh
	mesh.position = Vector3(0, 0.8, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.5, 0.9)
	mat.metallic = 0.2
	mat.roughness = 0.6
	mesh.material_override = mat
	add_child(mesh)

	# Hat
	var hat := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.3, 0.1, 0.3)
	hat.mesh = box
	hat.position = Vector3(0, 1.7, 0)
	var hat_mat := StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.9, 0.6, 0.2)
	hat.material_override = hat_mat
	add_child(hat)

	# Camera arm (SpringArm3D handles collision automatically)
	_camera_arm = SpringArm3D.new()
	_camera_arm.name = "CameraArm"
	_camera_arm.spring_length = 8.0
	_camera_arm.position = Vector3(0, 1.5, 0)
	_camera_arm.rotation.x = _pitch
	add_child(_camera_arm)

	# Camera at the end of the arm
	var camera := Camera3D.new()
	camera.name = "Camera"
	_camera_arm.add_child(camera)


func _unhandled_input(event: InputEvent) -> void:
	# Mouse look — rotates camera arm, NOT the character
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_yaw -= event.relative.x * MOUSE_SENSITIVITY
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENSITIVITY, -1.2, 0.2)
		_camera_arm.rotation.x = _pitch
		# Rotate the whole character for yaw (camera follows)
		rotation.y = _yaw

	# Scroll to zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera_arm.spring_length = maxf(_camera_arm.spring_length - 0.5, 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera_arm.spring_length = minf(_camera_arm.spring_length + 0.5, 15.0)


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# WASD movement relative to camera facing direction
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

	# Movement direction relative to camera yaw
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, _yaw)

	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# Rotate character mesh to face movement direction (visual only)
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
		velocity.z = move_toward(velocity.z, 0, SPEED * 0.2)

	move_and_slide()
