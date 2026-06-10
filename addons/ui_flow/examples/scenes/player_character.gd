## Player Character — top-down shooter with gun attack + VFX.
extends CharacterBody3D

const SPEED := 6.0
const ATTACK_COOLDOWN := 0.15
const ATTACK_RANGE := 50.0
const KNOCKBACK_FORCE := 8.0

var stats: Resource = null
var _attack_timer: float = 0.0
var _top_down: bool = false

@onready var _model: Node3D = $Model
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera_arm: SpringArm3D = $CameraPivot/CameraArm
@onready var _gun_tip: Node3D = $Model/GunTip


func _ready() -> void:
	add_to_group("player")


func set_top_down_camera() -> void:
	_top_down = true
	_camera_pivot.rotation_degrees = Vector3(-60, 0, 0)
	_camera_arm.spring_length = 12.0


func _input(event: InputEvent) -> void:
	if _top_down:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_camera_arm.spring_length = maxf(_camera_arm.spring_length - 0.5, 4.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_camera_arm.spring_length = minf(_camera_arm.spring_length + 0.5, 20.0)
	else:
		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_camera_pivot.rotation.y -= event.relative.x * 0.003
			_camera_arm.rotation.x = clampf(_camera_arm.rotation.x - event.relative.y * 0.003, -1.2, 0.2)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	_attack_timer = maxf(_attack_timer - delta, 0.0)

	# Auto-fire while holding click
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_shoot()

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
		velocity.x = input_dir.x * SPEED
		velocity.z = input_dir.y * SPEED

		# Face mouse
		var mouse_pos := get_viewport().get_mouse_position()
		var camera := get_viewport().get_camera_3d()
		if camera:
			var ray_origin := camera.project_ray_origin(mouse_pos)
			var ray_dir := camera.project_ray_normal(mouse_pos)
			if absf(ray_dir.y) > 0.001:
				var t := -ray_origin.y / ray_dir.y
				var ground_pos := ray_origin + ray_dir * t
				var look_dir := ground_pos - global_position
				if look_dir.length() > 0.1:
					_model.rotation.y = lerp_angle(_model.rotation.y, atan2(look_dir.x, look_dir.z), 0.3)
	else:
		var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, _camera_pivot.rotation.y)
		if direction.length() > 0.01:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			_model.rotation.y = lerp_angle(_model.rotation.y, atan2(direction.x, direction.z), 0.15)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
			velocity.z = move_toward(velocity.z, 0, SPEED * 0.2)

	move_and_slide()


func _shoot() -> void:
	if _attack_timer > 0:
		return
	_attack_timer = ATTACK_COOLDOWN

	var attack_power: int = 10
	if stats and "attack" in stats:
		attack_power = stats.attack

	# Raycast from gun tip forward
	var gun_pos: Vector3 = _gun_tip.global_position if _gun_tip else global_position + Vector3(0, 1, 0)
	var forward: Vector3 = -_model.global_transform.basis.z
	var from: Vector3 = gun_pos
	var to: Vector3 = from + forward * ATTACK_RANGE

	# Spawn muzzle flash
	_spawn_muzzle_flash(gun_pos, forward)

	# Raycast for hit detection
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	var result := space.intersect_ray(query)

	var hit_pos: Vector3 = to
	if result:
		hit_pos = result.position
		var collider = result.collider

		# Check if hit an enemy
		if collider.is_in_group("enemies") and collider.has_method("take_damage"):
			var enemy_stats = collider.get("stats")
			if enemy_stats and enemy_stats.is_alive():
				collider.take_damage(attack_power)

				# Knockback
				var kb_dir := (collider.global_position - global_position).normalized()
				if collider is CharacterBody3D:
					collider.velocity = kb_dir * KNOCKBACK_FORCE

				# Show damage number
				var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
				if hud:
					hud.show_damage_number(attack_power, collider.global_position + Vector3(0, 2, 0))

		# Spawn impact effect
		_spawn_impact(hit_pos, result.normal if result else Vector3.UP)
	else:
		_spawn_impact(hit_pos, Vector3.UP)

	# Bullet trail
	_spawn_bullet_trail(gun_pos, hit_pos)


func _spawn_muzzle_flash(pos: Vector3, dir: Vector3) -> void:
	# Simple flash: a small bright mesh
	var flash := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.08
	sphere.height = 0.16
	flash.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(1, 0.9, 0.5)
	mat.emission_energy_multiplier = 5.0
	mat.albedo_color = Color(1, 0.9, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = mat
	flash.position = pos
	flash.scale = Vector3(1, 1, 2)  # Elongated in shoot direction
	flash.look_at(pos + dir, Vector3.UP)
	add_child(flash)

	# Fade out quickly
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.1)
	tween.finished.connect(flash.queue_free)


func _spawn_impact(pos: Vector3, normal: Vector3) -> void:
	# Impact spark
	var spark := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	spark.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(1, 0.8, 0.3)
	mat.emission_energy_multiplier = 3.0
	mat.albedo_color = Color(1, 0.8, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spark.material_override = mat
	spark.position = pos + normal * 0.05
	add_child(spark)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(spark, "scale", Vector3(0.01, 0.01, 0.01), 0.2)
	tween.tween_property(spark, "modulate:a", 0.0, 0.2)
	tween.finished.connect(spark.queue_free)


func _spawn_bullet_trail(from: Vector3, to: Vector3) -> void:
	# Simple line trail
	var trail := MeshInstance3D.new()
	var mid := (from + to) / 2.0
	var dist := from.distance_to(to)
	var box := BoxMesh.new()
	box.size = Vector3(0.02, 0.02, dist)
	trail.mesh = box
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(1, 0.9, 0.6)
	mat.emission_energy_multiplier = 2.0
	mat.albedo_color = Color(1, 0.9, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail.material_override = mat
	trail.global_position = mid
	trail.look_at(to, Vector3.UP)
	add_child(trail)

	var tween := create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.15)
	tween.finished.connect(trail.queue_free)


func take_damage(amount: float) -> void:
	if stats and "health" in stats:
		stats.health -= amount
		# Screen shake
		var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
		if hud:
			hud.show_damage_flash()
			hud.shake_camera(0.2, 6.0)
		if stats.health <= 0:
			print("Player died!")
