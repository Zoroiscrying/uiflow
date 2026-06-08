## Settings menu — shows navigation depth.
## Transitions configured in Inspector (.tscn).
class_name SettingsMenuScreen extends UIFlowPage

@onready var _back_button: Button = $Center/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	UIFlow.pop()


func _on_back() -> void:
	UIFlow.pop()


func _on_opened(_data: Dictionary = {}) -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus(_back_button)


func _on_shown() -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus(_back_button)
