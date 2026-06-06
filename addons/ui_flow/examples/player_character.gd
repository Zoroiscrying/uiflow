## Player Character — simple 3D character with WASD movement and camera follow.
extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.002

var _camera_pivot: Node3D
var _camera: Camera3D
var _yaw: float = 0.0
var _pitch: float = -0.3


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

	# Camera pivot (follows rotation)
	_camera_pivot = Node3D.new()
	_camera_pivot.name = "CameraPivot"
	add_child(_camera_pivot)

	# Camera (offset behind and above)
	_camera = Camera3D.new()
	_camera.name = "Camera"
	_camera.position = Vector3(0, 2.5, 5)
	_camera_pivot.add_child(_camera)

	# Add a hat/indicator on top
	var hat := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.3, 0.1, 0.3)
	hat.mesh = box
	hat.position = Vector3(0, 1.7, 0)

	var hat_mat := StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.9, 0.6, 0.2)
	hat.material_override = hat_mat
	add_child(hat)

	# Capture mouse for camera control
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Mouse look
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * MOUSE_SENSITIVITY
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENSITIVITY, -0.8, 0.3)

	# Release mouse with Escape
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement direction relative to camera
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

	# Rotate movement by camera yaw
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, _yaw)

	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# Rotate character to face movement direction
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
		velocity.z = move_toward(velocity.z, 0, SPEED * 0.2)

	move_and_slide()

	# Update camera pivot rotation
	_camera_pivot.rotation.y = _yaw
	_camera.rotation.x = _pitch
