## Credits screen - simple page with back navigation.
class_name CreditsScreen extends UIFlowPage

@onready var _back_button: Button = $Center/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	UIFlow.pop()


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus(_back_button)
