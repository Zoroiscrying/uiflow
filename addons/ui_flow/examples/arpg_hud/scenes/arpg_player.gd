## ARPG Player — third-person character with combat.
extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.003
const ATTACK_RANGE := 2.5
const ATTACK_COOLDOWN := 0.5

@export var stats: ARPGPlayerStats

var _yaw: float = 0.0
var _pitch: float = -0.4
var _attack_timer: float = 0.0

@onready var _model: Node3D = $Model
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera_arm: SpringArm3D = $CameraPivot/CameraArm
@onready var _attack_area: Area3D = $AttackArea


func _ready() -> void:
	add_to_group("player")
	if stats == null:
		stats = ARPGPlayerStats.new()
	_camera_arm.rotation.x = _pitch

	# Connect attack area
	_attack_area.body_entered.connect(_on_attack_area_body_entered)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_yaw -= event.relative.x * MOUSE_SENSITIVITY
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENSITIVITY, -1.2, 0.2)
		_camera_pivot.rotation.y = _yaw
		_camera_arm.rotation.x = _pitch

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_camera_arm.spring_length = maxf(_camera_arm.spring_length - 0.5, 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_camera_arm.spring_length = minf(_camera_arm.spring_length + 0.5, 15.0)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1
	if Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	input_dir = input_dir.normalized()

	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, _yaw)

	if direction.length() > 0.01:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var target_yaw := atan2(direction.x, direction.z)
		_model.rotation.y = lerp_angle(_model.rotation.y, target_yaw, 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)
		velocity.z = move_toward(velocity.z, 0, SPEED * 0.2)

	move_and_slide()

	# Attack cooldown
	_attack_timer = maxf(_attack_timer - delta, 0.0)

	# Attack input (left click or E)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_E):
		_attack()


func _attack() -> void:
	if _attack_timer > 0:
		return
	_attack_timer = ATTACK_COOLDOWN

	# Check for enemies in range
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist <= ATTACK_RANGE:
			var enemy_stats: ARPGEnemyStats = enemy.get("stats")
			if enemy_stats and enemy_stats.is_alive():
				enemy_stats.take_damage(stats.attack)
				# Show damage number
				var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
				if hud:
					hud.show_damage_number(stats.attack, enemy.global_position + Vector3(0, 2, 0))
				# Knockback
				var knockback_dir: Vector3 = (enemy.global_position - global_position).normalized()
				enemy.velocity = knockback_dir * 5.0


func _on_attack_area_body_entered(body: Node3D) -> void:
	pass  # Future: auto-target nearest enemy


func take_damage(amount: float) -> void:
	stats.take_damage(amount)
	var hud := UIFlow.get_page(ARPGHUDPage) as ARPGHUDPage
	if hud:
		hud.show_damage_flash()
	if stats.health <= 0:
		_die()


func _die() -> void:
	print("Player died!")
	# Future: death screen, respawn, etc.
