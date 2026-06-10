## SurvivorsHUDPage — game HUD with UIFlow bindings showcase.
class_name SurvivorsHUDPage extends UIFlowPage

@export var player_stats: SurvivorsPlayerStats

@onready var _health_bar: ProgressBar = $HUD/Margin/VBox/HealthRow/HealthBar
@onready var _health_label: Label = $HUD/Margin/VBox/HealthRow/HealthLabel
@onready var _xp_bar: ProgressBar = $HUD/Margin/VBox/XPBar
@onready var _level_label: Label = $HUD/Margin/VBox/LevelLabel
@onready var _gold_label: Label = $HUD/Margin/VBox/GoldLabel
@onready var _wave_label: Label = $HUD/Margin/VBox/WaveLabel
@onready var _weapon_slots: HBoxContainer = $HUD/Margin/VBox/WeaponSlots

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []
var _damage_overlay: ColorRect
var _shake_tween: Tween
var _health_style: UIFlowDataStyle


func shake_camera(duration: float = 0.2, intensity: float = 6.0) -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	var original_pos: Vector2 = position
	_shake_tween = create_tween()
	var steps := 4
	for i in range(steps):
		var offset := Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		) * (1.0 - float(i) / steps)
		_shake_tween.tween_property(self, "position", original_pos + offset, duration / steps)
	_shake_tween.tween_property(self, "position", original_pos, duration / steps)


func _on_opened(_data: Variant = null) -> void:
	if player_stats == null and _data is Dictionary:
		player_stats = _data.get("player_stats", null)
	if player_stats == null:
		return

	for b in _bindings:
		b.unbind()
	_bindings.clear()

	# Health — bind_signal for bar, bind_signal_t for label
	_bindings.append(UIFlow.bind_signal(_health_bar, "value", player_stats.health_changed))
	_bindings.append(UIFlow.bind_signal_t(_health_label, "text", player_stats.health_changed,
		func(v): return "%d / %d" % [int(v), int(player_stats.max_health)]))

	# UIFlowDataStyle: pulse when health < 25%
	if _health_style == null:
		_health_style = UIFlowDataStyle.new()
		_health_style.add_rule(func(v): return v < player_stats.max_health * 0.25, {"pulse": true})
		_health_bar.add_child(_health_style)
	_health_style.bind_signal(player_stats.health_changed)

	# XP
	_bindings.append(UIFlow.bind_signal(_xp_bar, "value", player_stats.xp_changed))

	# Level
	_bindings.append(UIFlow.bind_signal_t(_level_label, "text", player_stats.level_changed,
		func(v): return "Lv. %d" % v))

	# Gold
	_bindings.append(UIFlow.bind_signal_t(_gold_label, "text", player_stats.gold_changed,
		func(v): return "%d G" % v))

	# Weapon slots — rebuild on weapons_changed
	player_stats.weapons_changed.connect(_rebuild_weapon_slots)
	_rebuild_weapon_slots()

	# Initialize display
	_health_bar.max_value = player_stats.max_health
	_health_bar.value = player_stats.health
	_xp_bar.max_value = player_stats.xp_to_next
	_xp_bar.value = player_stats.xp


func _rebuild_weapon_slots() -> void:
	UIFlowUtils.clear_children(_weapon_slots)
	for weapon in player_stats.get_weapons():
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(48, 48)

		var icon := TextureRect.new()
		icon.texture = weapon.icon if weapon.icon else null
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot.add_child(icon)

		_weapon_slots.add_child(slot)

		# UIFlowTooltip
		UIFlowTooltip.attach(slot, "%s\nDMG: %d | CD: %.1fs" % [weapon.weapon_name, weapon.damage, weapon.cooldown])


func _on_closed() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()
	if player_stats and player_stats.weapons_changed.is_connected(_rebuild_weapon_slots):
		player_stats.weapons_changed.disconnect(_rebuild_weapon_slots)


func show_damage_flash() -> void:
	if _damage_overlay == null:
		_damage_overlay = ColorRect.new()
		_damage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		_damage_overlay.color = Color(1, 0, 0, 0.3)
		_damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_damage_overlay)
	_damage_overlay.modulate.a = 0.4
	var tween: Tween = create_tween()
	tween.tween_property(_damage_overlay, "modulate:a", 0.0, 0.5)


func show_wave_start(wave: int) -> void:
	_wave_label.text = "Wave %d" % wave
	_wave_label.visible = true
	_wave_label.modulate.a = 1.0
	UIFlowUI.Toast.show_toast("Wave %d incoming!" % wave, "warning", 2.0)
	var tween: Tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(_wave_label, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): _wave_label.visible = false)


func show_damage_number(amount: int, world_pos: Vector3) -> void:
	var label := Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	var camera := get_viewport().get_camera_3d()
	if camera:
		var screen_pos := camera.unproject_position(world_pos)
		label.position = screen_pos - Vector2(20, 40)
	var container := get_parent()
	if container:
		container.add_child(label)
	else:
		add_child(label)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.finished.connect(label.queue_free)
