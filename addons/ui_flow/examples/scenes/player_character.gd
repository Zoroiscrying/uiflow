## Player Character — supports both third-person and top-down modes.
extends CharacterBody3D

const SPEED := 6.0
const ATTACK_RANGE := 2.5
const ATTACK_COOLDOWN := 0.3

var stats: Resource = null
var _attack_timer: float = 0.0
var _top_down: bool = false

@onready var _model: Node3D = $Model
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera_arm: SpringArm3D = $CameraPivot/CameraArm


func _ready() -> void:
	add_to_group("player")


## Switch to top-down camera (Brotato-like).
func set_top_down_camera() -> void:
	_top_down = true
	_camera_pivot.rotation_degrees = Vector3(-60, 0, 0)
	_camera_arm.spring_length = 12.0
	_camera_arm.position = Vector3(0, 0, 0)


func _input(event: InputEvent) -> void:
	if _top_down:
		# Scroll → zoom only
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_camera_arm.spring_length = maxf(_camera_arm.spring_length - 0.5, 4.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_camera_arm.spring_length = minf(_camera_arm.spring_length + 0.5, 20.0)
	else:
		# Third-person: right-mouse-drag → rotate camera
		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			var sensitivity := 0.003
			_camera_pivot.rotation.y -= event.relative.x * sensitivity
			_camera_arm.rotation.x = clampf(
				_camera_arm.rotation.x - event.relative.y * sensitivity, -1.2, 0.2
			)
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_camera_arm.spring_length = maxf(_camera_arm.spring_length - 0.5, 2.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_camera_arm.spring_length = minf(_camera_arm.spring_length + 0.5, 15.0)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Attack
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_E):
		_attack()

	# WASD movement
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

	if _top_down:
		# Top-down: movement is world-relative, model faces mouse
		velocity.x = input_dir.x * SPEED
		velocity.z = input_dir.y * SPEED

		# Face mouse position
		var mouse_pos := get_viewport().get_mouse_position()
		var camera := get_viewport().get_camera_3d()
		if camera:
			var ray_origin := camera.project_ray_origin(mouse_pos)
			var ray_dir := camera.project_ray_normal(mouse_pos)
			# Intersect with ground plane (y = 0)
			if absf(ray_dir.y) > 0.001:
				var t := -ray_origin.y / ray_dir.y
				var ground_pos := ray_origin + ray_dir * t
				var look_dir := ground_pos - global_position
				if look_dir.length() > 0.1:
					var target_yaw := atan2(look_dir.x, look_dir.z)
					_model.rotation.y = lerp_angle(_model.rotation.y, target_yaw, 0.2)
	else:
		# Third-person: movement relative to camera
		var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, _camera_pivot.rotation.y)
		if direction.length() > 0.01:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			var target_yaw := atan2(direction.x, direction.z)
			_model.rotation.y = lerp_angle(_model.rotation.y, target_yaw, 0.15)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
			velocity.z = move_toward(velocity.z, 0, SPEED * 0.2)

	move_and_slide()


func _attack() -> void:
	if _attack_timer > 0:
		return
	_attack_timer = ATTACK_COOLDOWN

	var attack_power: int = 10
	if stats and "attack" in stats:
		attack_power = stats.attack

	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist <= ATTACK_RANGE:
			if enemy.has_method("take_damage"):
				var enemy_stats = enemy.get("stats")
				if enemy_stats and enemy_stats.is_alive():
					enemy.take_damage(attack_power)
					var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
					if hud:
						hud.show_damage_number(attack_power, enemy.global_position + Vector3(0, 2, 0))


func take_damage(amount: float) -> void:
	if stats and "health" in stats:
		stats.health -= amount
		var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
		if hud:
			hud.show_damage_flash()
		if stats.health <= 0:
			print("Player died!")
