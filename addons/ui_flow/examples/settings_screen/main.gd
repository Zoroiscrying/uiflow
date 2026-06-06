## Settings Screen example — demonstrates two-way data binding.
extends Control

@export var settings: SettingsData

func _ready() -> void:
	if settings == null:
		settings = SettingsData.new()

	var page: SettingsPage = UIFlow.push(SettingsPage) as SettingsPage
	page.settings = settings
