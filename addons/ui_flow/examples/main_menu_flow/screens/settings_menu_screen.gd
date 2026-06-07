## Settings menu placeholder - shows navigation depth.
## BackButton connected via Inspector signal in .tscn.
class_name SettingsMenuScreen extends UIFlowPage


func _on_back_pressed() -> void:
	print("SettingsMenuScreen: Back pressed! Stack depth: ", UIFlow.stack_depth())
	UIFlow.pop()
	print("SettingsMenuScreen: Pop done. Stack depth: ", UIFlow.stack_depth())


func _on_enter(_data: Dictionary = {}) -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)


func _on_resume() -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)
