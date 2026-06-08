## Settings page — demonstrates two-way data binding with sliders and toggles.
class_name SettingsPageExample extends UIFlowPage

@export var settings: SettingsData

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []


func _on_back_pressed() -> void:
	UIFlow.pop()


func _on_back() -> void:
	UIFlow.pop()


func _on_opened(_data: Dictionary = {}) -> void:
	if settings == null:
		settings = SettingsData.new()

	# Clean up old bindings before creating new ones
	for b in _bindings:
		b.unbind()
	_bindings.clear()

	# Bind sliders (two-way: UI ↔ data)
	_bindings.append(
		UIFlow.bind_slider($Margin/Center/MasterVolume/Slider, settings.master_volume_changed,
			func(v): settings.master_volume = v)
	)
	_bindings.append(
		UIFlow.bind_slider($Margin/Center/MusicVolume/Slider, settings.music_volume_changed,
			func(v): settings.music_volume = v)
	)
	_bindings.append(
		UIFlow.bind_slider($Margin/Center/SFXVolume/Slider, settings.sfx_volume_changed,
			func(v): settings.sfx_volume = v)
	)

	# Bind labels to display values
	_bindings.append(
		UIFlow.bind_signal_t($Margin/Center/MasterVolume/Value, "text", settings.master_volume_changed,
			func(v): return "%d%%" % int(v))
	)
	_bindings.append(
		UIFlow.bind_signal_t($Margin/Center/MusicVolume/Value, "text", settings.music_volume_changed,
			func(v): return "%d%%" % int(v))
	)
	_bindings.append(
		UIFlow.bind_signal_t($Margin/Center/SFXVolume/Value, "text", settings.sfx_volume_changed,
			func(v): return "%d%%" % int(v))
	)

	# Bind toggles
	$Margin/Center/Fullscreen/CheckButton.toggled.connect(func(v): settings.fullscreen = v)
	$Margin/Center/VSync/CheckButton.toggled.connect(func(v): settings.vsync = v)

	# Initialize values
	$Margin/Center/MasterVolume/Slider.value = settings.master_volume
	$Margin/Center/MusicVolume/Slider.value = settings.music_volume
	$Margin/Center/SFXVolume/Slider.value = settings.sfx_volume
	$Margin/Center/Fullscreen/CheckButton.button_pressed = settings.fullscreen
	$Margin/Center/VSync/CheckButton.button_pressed = settings.vsync

	UIFlow.set_default_focus($Margin/Center/MasterVolume/Slider)


func _on_closed() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()
