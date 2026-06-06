## Settings menu placeholder — shows navigation depth.
class_name SettingsMenuScreen extends UIFlowPage


func _ready() -> void:
	$Center/BackButton.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	UIFlow.pop()


func _on_enter(_data: Dictionary = {}) -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)


func _on_resume() -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)
