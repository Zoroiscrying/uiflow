## XpGem — collectible XP pickup with auto-attract to player.
extends Area3D

var xp_amount: float = 10.0
var _attracted: bool = false
var _player: Node3D = null
const ATTRACT_RANGE := 3.0
const COLLECT_RANGE := 0.5
const MOVE_SPEED := 8.0


func _ready() -> void:
	# Visual: small green glowing sphere
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(0.2, 1.0, 0.3)
	mat.emission_energy_multiplier = 3.0
	mat.albedo_color = Color(0.2, 1.0, 0.3)
	mesh.material_override = mat
	add_child(mesh)

	# Collision
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.3
	collision.shape = shape
	add_child(collision)

	# Find player
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	var dist := global_position.distance_to(_player.global_position)

	if dist < COLLECT_RANGE:
		_collect()
		return

	if dist < ATTRACT_RANGE:
		_attracted = true

	if _attracted:
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * MOVE_SPEED * delta


func _collect() -> void:
	var event_bus := _get_event_bus()
	if event_bus:
		event_bus.xp_gained.emit(xp_amount)
	queue_free()


func _get_event_bus() -> SurvivorsEventBus:
	# Try autoload first
	if Engine.has_singleton("SurvivorsEventBus"):
		return Engine.get_singleton("SurvivorsEventBus")
	# Fallback: find in scene
	var root := get_tree().current_scene
	if root:
		for child in root.get_children():
			if child is SurvivorsEventBus:
				return child
	return null
