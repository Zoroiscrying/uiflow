## Example settings page — demonstrates push/pop with back navigation.
class_name SettingsPage extends UIFlowPage

func _ready() -> void:
	$VBox/AudioButton.pressed.connect(_on_audio_pressed)
	$VBox/BackButton.pressed.connect(_on_back_pressed)


func _on_opened(_data: Dictionary = {}) -> void:
	print("[SettingsPage] Enter")


func _on_closed() -> void:
	print("[SettingsPage] Exit")


func _on_hidden() -> void:
	print("[SettingsPage] Pause")


func _on_shown() -> void:
	print("[SettingsPage] Resume")


func _on_audio_pressed() -> void:
	# Navigate deeper (could push another page)
	print("[SettingsPage] Audio settings clicked")


func _on_back_pressed() -> void:
	UIFlow.pop()
