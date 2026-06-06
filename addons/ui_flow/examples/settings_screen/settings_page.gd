## Settings page — demonstrates two-way data binding with sliders and toggles.
extends UIFlowPage

@export var settings: SettingsData

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []


func _on_enter(_data: Dictionary = {}) -> void:
	if settings == null:
		settings = SettingsData.new()

	# Bind sliders (two-way: UI ↔ data)
	_bindings.append(
		UIFlow.bind_slider($VBox/MasterVolume/Slider, settings.master_volume_changed,
			func(v): settings.master_volume = v)
	)
	_bindings.append(
		UIFlow.bind_slider($VBox/MusicVolume/Slider, settings.music_volume_changed,
			func(v): settings.music_volume = v)
	)
	_bindings.append(
		UIFlow.bind_slider($VBox/SFXVolume/Slider, settings.sfx_volume_changed,
			func(v): settings.sfx_volume = v)
	)

	# Bind labels to display values
	_bindings.append(
		UIFlow.bind_signal_t($VBox/MasterVolume/Value, "text", settings.master_volume_changed,
			func(v): return "%d%%" % int(v))
	)
	_bindings.append(
		UIFlow.bind_signal_t($VBox/MusicVolume/Value, "text", settings.music_volume_changed,
			func(v): return "%d%%" % int(v))
	)
	_bindings.append(
		UIFlow.bind_signal_t($VBox/SFXVolume/Value, "text", settings.sfx_volume_changed,
			func(v): return "%d%%" % int(v))
	)

	# Bind toggles
	$VBox/Fullscreen/CheckButton.toggled.connect(func(v): settings.fullscreen = v)
	$VBox/VSync/CheckButton.toggled.connect(func(v): settings.vsync = v)

	# Initialize values
	$VBox/MasterVolume/Slider.value = settings.master_volume
	$VBox/MusicVolume/Slider.value = settings.music_volume
	$VBox/SFXVolume/Slider.value = settings.sfx_volume
	$VBox/Fullscreen/CheckButton.button_pressed = settings.fullscreen
	$VBox/VSync/CheckButton.button_pressed = settings.vsync

	UIFlow.set_default_focus($VBox/MasterVolume/Slider)


func _on_exit() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()
