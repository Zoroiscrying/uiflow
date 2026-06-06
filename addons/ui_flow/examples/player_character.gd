## Player Character — WASD movement with fixed camera, no mouse capture.
## Mouse remains free for UI interaction.
extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5


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

	# Hat indicator
	var hat := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.3, 0.1, 0.3)
	hat.mesh = box
	hat.position = Vector3(0, 1.7, 0)
	var hat_mat := StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.9, 0.6, 0.2)
	hat.material_override = hat_mat
	add_child(hat)

	# Fixed camera — elevated behind-player view (no mouse control)
	_camera = Camera3D.new()
	_camera.name = "Camera"
	_camera.position = Vector3(0, 8, 10)
	_camera.look_at(Vector3(0, 0, 0))
	add_child(_camera)


var _camera: Camera3D


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# WASD movement (world-relative, no camera rotation)
	var direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.z -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.z += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1

	direction = direction.normalized()

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
