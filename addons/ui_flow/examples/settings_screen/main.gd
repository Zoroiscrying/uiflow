## Settings Screen example — demonstrates two-way data binding.
extends Control

@export var settings: SettingsData

func _ready() -> void:
	if settings == null:
		settings = SettingsData.new()

	var page: SettingsPageExample = UIFlow.push(SettingsPageExample) as SettingsPageExample
	page.settings = settings
