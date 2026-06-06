## Credits screen — simple page with back navigation.
class_name CreditsScreen extends UIFlowPage

func _ready() -> void:
	$Center/BackButton.pressed.connect(func(): UIFlow.pop())


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus($Center/BackButton)
