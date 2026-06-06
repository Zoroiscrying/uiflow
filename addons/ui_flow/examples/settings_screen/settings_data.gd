## Settings data store — reactive settings with Signal-based binding.
class_name SettingsData extends UIFlowDataStore

signal master_volume_changed(value: float)
signal music_volume_changed(value: float)
signal sfx_volume_changed(value: float)
signal fullscreen_changed(value: bool)
signal vsync_changed(value: bool)
signal language_changed(value: String)

var master_volume: float = 80.0:
	set(v): master_volume = clampf(v, 0.0, 100.0); master_volume_changed.emit(master_volume)

var music_volume: float = 70.0:
	set(v): music_volume = clampf(v, 0.0, 100.0); music_volume_changed.emit(music_volume)

var sfx_volume: float = 90.0:
	set(v): sfx_volume = clampf(v, 0.0, 100.0); sfx_volume_changed.emit(sfx_volume)

var fullscreen: bool = false:
	set(v): fullscreen = v; fullscreen_changed.emit(fullscreen)

var vsync: bool = true:
	set(v): vsync = v; vsync_changed.emit(vsync)

var language: String = "English":
	set(v): language = v; language_changed.emit(language)
