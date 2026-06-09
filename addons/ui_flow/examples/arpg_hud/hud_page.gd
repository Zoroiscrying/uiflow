## ARPG HUD — dynamic health/mana/XP bars with animated transitions.
class_name ARPGHUDPage extends UIFlowPage

@export var player_stats: ARPGPlayerStats

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []
var _damage_overlay: ColorRect


func _on_opened(_data: Variant = null) -> void:
	# Read player_stats from data if not set via export
	if player_stats == null and _data is Dictionary:
		player_stats = _data.get("player_stats", null)
	if player_stats == null:
		return

	# Health bar binding
	_bindings.append(
		UIFlow.bind_signal($HUD/HealthBar, "value", player_stats.health_changed)
	)
	_bindings.append(
		UIFlow.bind_signal_t($HUD/HealthLabel, "text", player_stats.health_changed,
			func(v): return "%d / %d" % [int(v), int(player_stats.max_health)])
	)

	# Mana bar binding
	_bindings.append(
		UIFlow.bind_signal($HUD/ManaBar, "value", player_stats.mana_changed)
	)
	_bindings.append(
		UIFlow.bind_signal_t($HUD/ManaLabel, "text", player_stats.mana_changed,
			func(v): return "%d / %d" % [int(v), int(player_stats.max_mana)])
	)

	# XP bar binding
	_bindings.append(
		UIFlow.bind_signal($HUD/XPBar, "value", player_stats.xp_changed)
	)

	# Level binding
	_bindings.append(
		UIFlow.bind_signal_t($HUD/LevelLabel, "text", player_stats.level_changed,
			func(v): return "Lv. %d" % v)
	)

	# Gold binding
	_bindings.append(
		UIFlow.bind_signal_t($HUD/GoldLabel, "text", player_stats.gold_changed,
			func(v): return "💰 %d" % v)
	)

	# Health color change (green → yellow → red)
	_bindings.append(
		UIFlow.bind_signal($HUD/HealthBar, "tint_progress", player_stats.health_changed,
			# Note: this is a simple approach; the shader handles the actual gradient
		)
	)

	# Initialize
	$HUD/HealthBar.max_value = player_stats.max_health
	$HUD/HealthBar.value = player_stats.health
	$HUD/ManaBar.max_value = player_stats.max_mana
	$HUD/ManaBar.value = player_stats.mana
	$HUD/XPBar.max_value = player_stats.xp_to_next
	$HUD/XPBar.value = player_stats.xp


func _on_closed() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()


## Show a damage flash overlay.
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


## Show floating damage number at position.
func show_damage_number(amount: int, world_pos: Vector3) -> void:
	var label := Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)

	# Position in screen space
	var camera := get_viewport().get_camera_3d()
	if camera:
		var screen_pos := camera.unproject_position(world_pos)
		label.position = screen_pos - Vector2(20, 40)

	add_child(label)

	# Animate float up and fade
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.finished.connect(label.queue_free)
