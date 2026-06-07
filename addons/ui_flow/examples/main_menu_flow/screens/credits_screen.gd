## Credits screen - simple page with back navigation.
## BackButton connected via Inspector signal in .tscn.
class_name CreditsScreen extends UIFlowPage


func _on_back_pressed() -> void:
	UIFlow.pop()


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus($Center/BackButton)
