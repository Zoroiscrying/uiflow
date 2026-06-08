## Game World — enhances the 3D scene with trees, rocks, and atmosphere.
extends Node3D

func _ready() -> void:
	_add_trees()
	_add_rocks()
	_add_ground_details()


func _add_trees() -> void:
	var tree_positions := [
		Vector3(-6, 0, -6), Vector3(6, 0, -6), Vector3(-6, 0, 6),
		Vector3(7, 0, 3), Vector3(-5, 0, -2), Vector3(5, 0, 5),
		Vector3(-7, 0, 4), Vector3(8, 0, -3), Vector3(0, 0, -7),
	]

	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.35, 0.22, 0.12)

	var leaf_mat := StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.18, 0.45, 0.18)
	leaf_mat.emission_enabled = true
	leaf_mat.emission = Color(0.1, 0.3, 0.1)
	leaf_mat.emission_energy_multiplier = 0.15

	for pos in tree_positions:
		var tree := Node3D.new()
		tree.position = pos

		# Trunk
		var trunk := MeshInstance3D.new()
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.15
		trunk_mesh.bottom_radius = 0.2
		trunk_mesh.height = 2.0
		trunk.mesh = trunk_mesh
		trunk.material_override = trunk_mat
		trunk.position.y = 1.0
		tree.add_child(trunk)

		# Canopy
		var canopy := MeshInstance3D.new()
		var canopy_mesh := SphereMesh.new()
		canopy_mesh.radius = 1.2
		canopy_mesh.height = 1.8
		canopy.mesh = canopy_mesh
		canopy.material_override = leaf_mat
		canopy.position.y = 2.8
		canopy.scale = Vector3(1, 0.8, 1)
		tree.add_child(canopy)

		# Collision for trunk
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 0.2
		shape.height = 2.0
		col.shape = shape
		body.add_child(col)
		body.position.y = 1.0
		tree.add_child(body)

		add_child(tree)


func _add_rocks() -> void:
	var rock_positions := [
		Vector3(2, 0, -5), Vector3(-4, 0, 4), Vector3(6, 0, -2),
		Vector3(-2, 0, -4), Vector3(4, 0, 6),
	]

	var rock_mat := StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.35, 0.35, 0.38)
	rock_mat.roughness = 0.9

	for i in range(rock_positions.size()):
		var rock := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.4 + (i % 3) * 0.2
		mesh.height = 0.6 + (i % 2) * 0.3
		rock.mesh = mesh
		rock.material_override = rock_mat
		rock.position = rock_positions[i]
		rock.position.y = 0.2
		# Uniform scale (Jolt doesn't support non-uniform)
		var s := 0.6 + (i % 3) * 0.15
		rock.scale = Vector3(s, s, s)

		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 0.5
		col.shape = shape
		body.add_child(col)
		rock.add_child(body)

		add_child(rock)


func _add_ground_details() -> void:
	# Add some ground patches for visual variety
	var patch_mat := StandardMaterial3D.new()
	patch_mat.albedo_color = Color(0.1, 0.15, 0.1)

	var patch_positions := [
		Vector3(-3, -0.48, 2), Vector3(4, -0.48, -4), Vector3(0, -0.48, 5),
	]

	for pos in patch_positions:
		var patch := MeshInstance3D.new()
		var mesh := PlaneMesh.new()
		mesh.size = Vector2(2.5, 2.5)
		patch.mesh = mesh
		patch.material_override = patch_mat
		patch.position = pos
		add_child(patch)
