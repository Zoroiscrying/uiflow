## Transition demo page — shown when a transition button is pressed.
class_name TransitionDemoPage extends UIFlowPage

var _transition_name: String = ""


func set_transition_name(name: String) -> void:
	_transition_name = name


func _on_enter(_data: Dictionary = {}) -> void:
	$VBox/NameLabel.text = "Transition: %s" % _transition_name
	$VBox/BackButton.pressed.connect(func(): UIFlow.pop())
	UIFlow.set_default_focus($VBox/BackButton)
