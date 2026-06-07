## Settings menu placeholder - shows navigation depth.
class_name SettingsMenuScreen extends UIFlowPage


func _on_back_pressed() -> void:
	print("SettingsMenuScreen: _on_back_pressed called!")
	UIFlow.pop()


func _on_enter(_data: Dictionary = {}) -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)
	print("SettingsMenuScreen: _on_enter, BackButton = ", $Center/BackButton)
	print("SettingsMenuScreen: BackButton pressed signal connections: ", $Center/BackButton.pressed.get_connections())


func _on_resume() -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)
