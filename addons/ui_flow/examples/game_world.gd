## Game World — a simple 3D environment running behind UIFlow UI.
##
## Creates a procedurally generated scene with rotating objects,
## demonstrating that UIFlow works seamlessly with real game content.
extends Node3D

var _objects: Array[Node3D] = []


func _ready() -> void:
	_create_ground()
	_create_objects()
	_create_lights()


func _process(delta: float) -> void:
	# Slowly rotate objects
	for i in range(_objects.size()):
		var obj: Node3D = _objects[i]
		if is_instance_valid(obj):
			obj.rotation.y += delta * (0.3 + i * 0.1)
			obj.rotation.x = sin(Time.get_ticks_msec() * 0.001 + i) * 0.1


func _create_ground() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	var plane := PlaneMesh.new()
	plane.size = Vector2(20, 20)
	ground.mesh = plane

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.15, 0.2)
	ground.material_override = mat
	ground.position = Vector3(0, -1, 0)
	add_child(ground)


func _create_objects() -> void:
	var colors: Array[Color] = [
		Color(0.3, 0.5, 0.9),   # Primary blue
		Color(0.9, 0.6, 0.2),   # Accent orange
		Color(0.3, 0.8, 0.4),   # Success green
		Color(0.9, 0.3, 0.3),   # Error red
		Color(0.7, 0.5, 0.9),   # Purple
		Color(0.4, 0.8, 0.9),   # Cyan
	]

	var positions: Array[Vector3] = [
		Vector3(-3, 0, -2),
		Vector3(0, 0, -3),
		Vector3(3, 0, -2),
		Vector3(-2, 0, 1),
		Vector3(2, 0, 1),
		Vector3(0, 0, 2),
	]

	var meshes: Array[Mesh] = [
		BoxMesh.new(),
		SphereMesh.new(),
		CylinderMesh.new(),
		BoxMesh.new(),
		SphereMesh.new(),
		TorusMesh.new(),
	]

	for i in range(colors.size()):
		var obj := MeshInstance3D.new()
		obj.name = "Object_%d" % i
		obj.mesh = meshes[i]
		obj.position = positions[i]
		obj.position.y = 0.0

		var mat := StandardMaterial3D.new()
		mat.albedo_color = colors[i]
		mat.metallic = 0.3
		mat.roughness = 0.4
		obj.material_override = mat

		add_child(obj)
		_objects.append(obj)


func _create_lights() -> void:
	# Directional light (sun)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 0.8
	sun.light_color = Color(1.0, 0.95, 0.9)
	add_child(sun)

	# Ambient light via environment
	var env := WorldEnvironment.new()
	env.name = "Environment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.05, 0.08)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.1, 0.1, 0.15)
	environment.ambient_light_energy = 0.5
	env.environment = environment
	add_child(env)

	# Camera
	var camera := Camera3D.new()
	camera.name = "Camera"
	camera.position = Vector3(0, 4, 7)
	camera.look_at(Vector3(0, 0, 0))
	add_child(camera)
