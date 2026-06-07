## Settings menu placeholder - shows navigation depth.
## BackButton connected via Inspector signal in .tscn.
class_name SettingsMenuScreen extends UIFlowPage


func _ready() -> void:
	print("SettingsMenuScreen: _ready called, node = ", name)
	print("SettingsMenuScreen: BackButton = ", $Center/BackButton)
	print("SettingsMenuScreen: pressed connections = ", $Center/BackButton.pressed.get_connections())


func _on_back_pressed() -> void:
	print("SettingsMenuScreen: BACK PRESSED!")
	UIFlow.pop()


func _on_opened(_data: Dictionary = {}) -> void:
	print("SettingsMenuScreen: _on_enter called")
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)


func _on_shown() -> void:
	$Center/DepthLabel.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus($Center/BackButton)
