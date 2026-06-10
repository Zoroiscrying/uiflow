## ARPG HUD — dynamic health/mana/XP bars with animated transitions.
class_name ARPGHUDPage extends UIFlowPage

@export var player_stats: ARPGPlayerStats

@onready var _health_bar: ProgressBar = $HUD/Margin/VBox/HealthRow/HealthBar
@onready var _health_label: Label = $HUD/Margin/VBox/HealthRow/HealthLabel
@onready var _mana_bar: ProgressBar = $HUD/Margin/VBox/ManaRow/ManaBar
@onready var _mana_label: Label = $HUD/Margin/VBox/ManaRow/ManaLabel
@onready var _xp_bar: ProgressBar = $HUD/Margin/VBox/XPBar
@onready var _level_label: Label = $HUD/Margin/VBox/LevelLabel
@onready var _gold_label: Label = $HUD/Margin/VBox/GoldLabel

@onready var _wave_label: Label = $HUD/Margin/VBox/WaveLabel

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []
var _damage_overlay: ColorRect
var _shake_tween: Tween


## Shake the HUD (screen shake effect).
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

	# Clean up old bindings
	for b in _bindings:
		b.unbind()
	_bindings.clear()

	# Health
	_bindings.append(
		UIFlow.bind_signal(_health_bar, "value", player_stats.health_changed)
	)
	_bindings.append(
		UIFlow.bind_signal_t(_health_label, "text", player_stats.health_changed,
			func(v): return "%d / %d" % [int(v), int(player_stats.max_health)])
	)

	# Mana
	_bindings.append(
		UIFlow.bind_signal(_mana_bar, "value", player_stats.mana_changed)
	)
	_bindings.append(
		UIFlow.bind_signal_t(_mana_label, "text", player_stats.mana_changed,
			func(v): return "%d / %d" % [int(v), int(player_stats.max_mana)])
	)

	# XP
	_bindings.append(
		UIFlow.bind_signal(_xp_bar, "value", player_stats.xp_changed)
	)

	# Level
	_bindings.append(
		UIFlow.bind_signal_t(_level_label, "text", player_stats.level_changed,
			func(v): return "Lv. %d" % v)
	)

	# Gold
	_bindings.append(
		UIFlow.bind_signal_t(_gold_label, "text", player_stats.gold_changed,
			func(v): return "💰 %d" % v)
	)

	# Initialize display
	_health_bar.max_value = player_stats.max_health
	_health_bar.value = player_stats.health
	_mana_bar.max_value = player_stats.max_mana
	_mana_bar.value = player_stats.mana
	_xp_bar.max_value = player_stats.xp_to_next
	_xp_bar.value = player_stats.xp


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


## Show wave start notification.
func show_wave_start(wave: int) -> void:
	_wave_label.text = "Wave %d" % wave
	_wave_label.visible = true
	UIFlowUI.Toast.show_toast("Wave %d incoming!" % wave, "warning", 2.0)


## Show wave complete notification.
func show_wave_complete(_wave: int) -> void:
	UIFlowUI.Toast.show_toast("Wave cleared! Next wave incoming...", "success", 2.0)


## Show floating damage number at position.
func show_damage_number(amount: int, world_pos: Vector3) -> void:
	var label := Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))

	var camera := get_viewport().get_camera_3d()
	if camera:
		var screen_pos := camera.unproject_position(world_pos)
		label.position = screen_pos - Vector2(20, 40)

	add_child(label)

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.finished.connect(label.queue_free)
