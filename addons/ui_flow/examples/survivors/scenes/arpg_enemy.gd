## Survivors Enemy — simple AI with health bar.
extends CharacterBody3D

const SPEED := 2.0
const ATTACK_RANGE := 2.0
const ATTACK_COOLDOWN := 1.0

@export var stats: SurvivorsEnemyStats

var _player: Node3D
var _attack_timer: float = 0.0
var _health_bar: ProgressBar


func _ready() -> void:
	add_to_group("enemies")
	if stats == null:
		stats = SurvivorsEnemyStats.new()
		stats.max_health = 50.0
		stats.health = 50.0

	# Collision shape
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	collision.shape = capsule
	collision.position = Vector3(0, 0.8, 0)
	add_child(collision)

	# Visual mesh
	var mesh := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.6
	mesh.mesh = capsule_mesh
	mesh.position = Vector3(0, 0.8, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.2, 0.2)
	mat.metallic = 0.2
	mat.roughness = 0.6
	mesh.material_override = mat
	add_child(mesh)

	# Health bar
	_create_health_bar()

	# Find player
	_player = get_tree().get_first_node_in_group("player")


func _create_health_bar() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(200, 20)
	viewport.transparent_bg = true
	viewport.handle_input_locally = false
	add_child(viewport)

	var bar := ProgressBar.new()
	bar.max_value = stats.max_health
	bar.value = stats.health
	bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar.show_percentage = false

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_style.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.2, 0.8, 0.3)
	fill_style.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", fill_style)

	viewport.add_child(bar)
	_health_bar = bar

	stats.health_changed.connect(func(v: float):
		bar.value = v
		var pct := v / stats.max_health
		if pct > 0.5:
			fill_style.bg_color = Color(0.2, 0.8, 0.3)
		elif pct > 0.25:
			fill_style.bg_color = Color(0.9, 0.8, 0.2)
		else:
			fill_style.bg_color = Color(0.9, 0.2, 0.2)
		bar.add_theme_stylebox_override("fill", fill_style)
	)

	var sprite := Sprite3D.new()
	sprite.texture = viewport.get_texture()
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.pixel_size = 0.01
	sprite.position = Vector3(0, 2.5, 0)
	add_child(sprite)


func _physics_process(delta: float) -> void:
	if not stats.is_alive():
		return

	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)

		if dist > ATTACK_RANGE:
			var dir := (_player.global_position - global_position).normalized()
			velocity.x = dir.x * SPEED
			velocity.z = dir.z * SPEED
			rotation.y = atan2(dir.x, dir.z)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			_attack_timer = maxf(_attack_timer - delta, 0.0)
			if _attack_timer <= 0:
				_attack_player()

	move_and_slide()


func _attack_player() -> void:
	_attack_timer = ATTACK_COOLDOWN
	if _player and _player.has_method("take_damage"):
		_player.take_damage(stats.attack)


func take_damage(amount: float) -> void:
	stats.take_damage(amount)
	_hit_flash()
	if not stats.is_alive():
		_die()


func _hit_flash() -> void:
	# Find mesh and flash white
	var mesh := find_child("Mesh", true, false) as MeshInstance3D
	if mesh and mesh.material_override:
		var original_color: Color = mesh.material_override.albedo_color
		mesh.material_override.albedo_color = Color.WHITE
		var tween := create_tween()
		tween.tween_property(mesh.material_override, "albedo_color", original_color, 0.15)


func _die() -> void:
	var player_stats: SurvivorsPlayerStats = _player.get("stats")
	if player_stats:
		player_stats.add_xp(25.0)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
	tween.finished.connect(queue_free)
