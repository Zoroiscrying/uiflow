## Game World — 3D environment with a movable player character.
##
## WASD/arrows to move, mouse to look, Space to jump, Escape to release mouse.
## UIFlow UI overlays on top while the game runs underneath.
extends Node3D

var _objects: Array[Node3D] = []
var _player: CharacterBody3D


func _ready() -> void:
	_create_ground()
	_create_environment_objects()
	_create_lights()
	_create_player()


func _process(delta: float) -> void:
	# Slowly rotate decorative objects
	for i in range(_objects.size()):
		var obj: Node3D = _objects[i]
		if is_instance_valid(obj):
			obj.rotation.y += delta * (0.3 + i * 0.08)
			obj.position.y = sin(Time.get_ticks_msec() * 0.001 + i * 0.7) * 0.15 + 0.5


func _create_ground() -> void:
	# Main ground
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	ground.mesh = plane

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.12, 0.16)
	ground.material_override = mat
	ground.position = Vector3(0, -0.5, 0)

	# Static body for collision
	var body := StaticBody3D.new()
	body.name = "GroundBody"
	var col := CollisionShape3D.new()
	var shape := WorldBoundaryShape3D.new()
	col.shape = shape
	body.add_child(col)
	ground.add_child(body)

	add_child(ground)

	# Grid lines (visual guide)
	_create_grid_lines()


func _create_grid_lines() -> void:
	var grid_mat := StandardMaterial3D.new()
	grid_mat.albedo_color = Color(0.2, 0.2, 0.25, 0.5)
	grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	for x in range(-15, 16, 3):
		var line := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.03, 0.01, 30)
		line.mesh = box
		line.material_override = grid_mat
		line.position = Vector3(x, -0.49, 0)
		add_child(line)

	for z in range(-15, 16, 3):
		var line := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(30, 0.01, 0.03)
		line.mesh = box
		line.material_override = grid_mat
		line.position = Vector3(0, -0.49, z)
		add_child(line)


func _create_environment_objects() -> void:
	var colors: Array[Color] = [
		Color(0.3, 0.5, 0.9),   # Primary blue
		Color(0.9, 0.6, 0.2),   # Accent orange
		Color(0.3, 0.8, 0.4),   # Success green
		Color(0.9, 0.3, 0.3),   # Error red
		Color(0.7, 0.5, 0.9),   # Purple
		Color(0.4, 0.8, 0.9),   # Cyan
		Color(0.9, 0.8, 0.3),   # Yellow
		Color(0.6, 0.3, 0.6),   # Magenta
	]

	var positions: Array[Vector3] = [
		Vector3(-4, 0, -3),
		Vector3(0, 0, -5),
		Vector3(4, 0, -3),
		Vector3(-3, 0, 2),
		Vector3(3, 0, 2),
		Vector3(0, 0, 4),
		Vector3(-6, 0, 0),
		Vector3(6, 0, 0),
	]

	var meshes: Array[Mesh] = [
		BoxMesh.new(),
		SphereMesh.new(),
		CylinderMesh.new(),
		BoxMesh.new(),
		SphereMesh.new(),
		TorusMesh.new(),
		CapsuleMesh.new(),
		PrismMesh.new(),
	]

	for i in range(colors.size()):
		# Pillar
		var pillar := MeshInstance3D.new()
		pillar.name = "Pillar_%d" % i
		var pillar_mesh := CylinderMesh.new()
		pillar_mesh.top_radius = 0.3
		pillar_mesh.bottom_radius = 0.35
		pillar_mesh.height = 2.0
		pillar.mesh = pillar_mesh

		var pillar_mat := StandardMaterial3D.new()
		pillar_mat.albedo_color = Color(0.18, 0.18, 0.22)
		pillar.material_override = pillar_mat
		pillar.position = positions[i]
		pillar.position.y = 0.5

		# Collision for pillar
		var pillar_body := StaticBody3D.new()
		var pillar_col := CollisionShape3D.new()
		var pillar_shape := CylinderShape3D.new()
		pillar_shape.radius = 0.35
		pillar_shape.height = 2.0
		pillar_col.shape = pillar_shape
		pillar_body.add_child(pillar_col)
		pillar.add_child(pillar_body)

		add_child(pillar)

		# Floating object on top
		var obj := MeshInstance3D.new()
		obj.name = "Object_%d" % i
		obj.mesh = meshes[i]

		var mat := StandardMaterial3D.new()
		mat.albedo_color = colors[i]
		mat.metallic = 0.4
		mat.roughness = 0.3
		mat.emission_enabled = true
		mat.emission = colors[i]
		mat.emission_energy_multiplier = 0.3
		obj.material_override = mat

		obj.position = positions[i]
		obj.position.y = 2.0
		# Scale down meshes
		if i == 1 or i == 4:  # Sphere
			obj.scale = Vector3(0.5, 0.5, 0.5)
		elif i == 5:  # Torus
			obj.scale = Vector3(0.4, 0.4, 0.4)

		add_child(obj)
		_objects.append(obj)

	# Add some walls/boundaries
	_create_walls()


func _create_walls() -> void:
	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.15, 0.15, 0.2)

	var wall_positions := [
		Vector3(0, 0.5, -10), Vector3(0, 0.5, 10),
		Vector3(-10, 0.5, 0), Vector3(10, 0.5, 0),
	]
	var wall_sizes := [
		Vector3(20, 1.5, 0.3), Vector3(20, 1.5, 0.3),
		Vector3(0.3, 1.5, 20), Vector3(0.3, 1.5, 20),
	]

	for i in range(4):
		var wall := MeshInstance3D.new()
		wall.name = "Wall_%d" % i
		var box := BoxMesh.new()
		box.size = wall_sizes[i]
		wall.mesh = box
		wall.material_override = wall_mat
		wall.position = wall_positions[i]

		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = wall_sizes[i]
		col.shape = shape
		body.add_child(col)
		wall.add_child(body)

		add_child(wall)


func _create_lights() -> void:
	# Directional light (sun)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 0.8
	sun.light_color = Color(1.0, 0.95, 0.9)
	sun.shadow_enabled = true
	add_child(sun)

	# Point lights near objects for atmosphere
	var light_positions := [
		Vector3(-4, 3, -3), Vector3(4, 3, 2), Vector3(0, 3, 4),
	]
	var light_colors := [
		Color(0.3, 0.5, 0.9), Color(0.9, 0.6, 0.2), Color(0.3, 0.8, 0.4),
	]

	for i in range(3):
		var light := OmniLight3D.new()
		light.name = "PointLight_%d" % i
		light.position = light_positions[i]
		light.light_color = light_colors[i]
		light.light_energy = 0.5
		light.omni_range = 8.0
		add_child(light)

	# Environment
	var env := WorldEnvironment.new()
	env.name = "Environment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.04, 0.04, 0.06)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.08, 0.08, 0.12)
	environment.ambient_light_energy = 0.4
	environment.tonemap_mode = Environment.TONE_MAP_ACES
	env.environment = environment
	add_child(env)


func _create_player() -> void:
	_player = preload("res://addons/ui_flow/examples/player_character.gd").new()
	_player.name = "Player"
	_player.position = Vector3(0, 0, 3)
	add_child(_player)
