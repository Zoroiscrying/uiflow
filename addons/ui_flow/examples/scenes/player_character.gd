## Player Character — top-down auto-shooter that targets nearest enemy.
extends CharacterBody3D

const SPEED := 6.0
const KNOCKBACK_FORCE := 8.0

var stats: SurvivorsPlayerStats = null
var _top_down: bool = false
var _weapon_manager: Node = null

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


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Auto-shoot via weapon manager
	if _weapon_manager and _weapon_manager.has_method("update"):
		var fired_weapon = _weapon_manager.update(delta, global_position)
		if fired_weapon:
			var target = _weapon_manager.get_target_for_weapon(fired_weapon, global_position)
			if target:
				_shoot_at(target, fired_weapon)

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

		# Face target, or mouse if no target
		var face_target := _get_face_target()
		if face_target:
			var look_dir := face_target.global_position - global_position
			look_dir.y = 0
			if look_dir.length() > 0.1:
				_model.rotation.y = lerp_angle(_model.rotation.y, atan2(look_dir.x, look_dir.z), 0.3)
		else:
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

	move_and_slide()


func _get_face_target() -> Node3D:
	if _weapon_manager and _weapon_manager.has_method("get_target_for_weapon") and stats:
		var weapons := stats.get_weapons()
		if weapons.size() > 0:
			return _weapon_manager.get_target_for_weapon(weapons[0], global_position)
	return null


func _shoot_at(target: Node3D, weapon: WeaponData) -> void:
	if target == null or not is_instance_valid(target):
		return

	var attack_power: int = weapon.damage + (stats.attack if stats else 0)
	var gun_pos: Vector3 = _gun_tip.global_position if _gun_tip else global_position + Vector3(0, 1, 0)
	var target_pos: Vector3 = target.global_position + Vector3(0, 0.8, 0)
	var shoot_dir: Vector3 = (target_pos - gun_pos).normalized()

	_spawn_muzzle_flash(gun_pos, shoot_dir)

	var enemy_stats: SurvivorsEnemyStats = target.get("stats")
	if enemy_stats and enemy_stats.is_alive():
		target.take_damage(attack_power)

		var kb_dir: Vector3 = (target.global_position - global_position).normalized()
		if target is CharacterBody3D:
			target.velocity = kb_dir * KNOCKBACK_FORCE

		var hud := UIFlow.get_page(SurvivorsHUDPage) as SurvivorsHUDPage
		if hud:
			hud.show_damage_number(attack_power, target.global_position + Vector3(0, 2, 0))

	_spawn_bullet_trail(gun_pos, target_pos)


func _spawn_muzzle_flash(pos: Vector3, dir: Vector3) -> void:
	var particles := GPUParticles3D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 8
	particles.lifetime = 0.15
	particles.explosiveness = 1.0

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.05
	mat.direction = dir
	mat.spread = 30.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0
	mat.gravity = Vector3.ZERO
	mat.scale_min = 0.3
	mat.scale_max = 0.6
	mat.color = Color(1, 0.9, 0.5)
	mat.color_ramp = _create_fade_ramp(Color(1, 0.9, 0.5, 1.0), Color(1, 0.6, 0.2, 0.0))
	particles.process_material = mat

	_add_vfx(particles, pos)
	particles.finished.connect(particles.queue_free)


func _spawn_bullet_trail(from: Vector3, to: Vector3) -> void:
	var dist := from.distance_to(to)
	if dist < 0.1:
		return

	var trail := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.02, 0.02, dist)
	trail.mesh = box
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(1, 0.9, 0.6)
	mat.emission_energy_multiplier = 2.0
	mat.albedo_color = Color(1, 0.9, 0.6, 1.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail.material_override = mat

	_add_vfx(trail, (from + to) / 2.0)
	trail.look_at(to, Vector3.UP)

	var tween := create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.15)
	tween.finished.connect(trail.queue_free)


func _add_vfx(node: Node3D, world_pos: Vector3) -> void:
	var root := get_tree().current_scene
	if root:
		root.add_child(node)
	else:
		add_child(node)
	node.global_position = world_pos


func _create_fade_ramp(start_color: Color, end_color: Color) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.set_color(0, start_color)
	gradient.set_offset(0, 0.0)
	gradient.set_color(1, end_color)
	gradient.set_offset(1, 1.0)
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture


func take_damage(amount: float) -> void:
	if stats == null:
		return
	stats.take_damage(amount)
	var hud := UIFlow.get_page(SurvivorsHUDPage) as SurvivorsHUDPage
	if hud:
		hud.show_damage_flash()
		hud.shake_camera(0.2, 6.0)
	if stats.health <= 0:
		_die()


func _die() -> void:
	print("Player died!")
	# Future: death screen, respawn, etc.
