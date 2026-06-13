## Transitions Demo — shows all available transition effects.
class_name UIFlowDemoTransitions extends UIFlowPage

const TransitionDemoPage = preload("res://addons/ui_flow/examples/component_gallery/transition_demo_page.gd")

@onready var _back_button: Button = $Panel/VBox/BackButton

var _transition_map: Dictionary = {}


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())

	_transition_map = {
		"Fade": UIFlowTransitionType.Type.FADE,
		"Slide Left": UIFlowTransitionType.Type.SLIDE_LEFT,
		"Slide Right": UIFlowTransitionType.Type.SLIDE_RIGHT,
		"Slide Up": UIFlowTransitionType.Type.SLIDE_UP,
		"Slide Down": UIFlowTransitionType.Type.SLIDE_DOWN,
		"Scale": UIFlowTransitionType.Type.SCALE,
	}

	# Connect transition buttons
	var buttons_node := $Panel/VBox/TransButtons
	for i in range(buttons_node.get_child_count()):
		var btn: Button = buttons_node.get_child(i)
		btn.pressed.connect(func(): _show_transition(btn.text))


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus($Panel/VBox/TransButtons.get_child(0) as Button)


func _show_transition(name: String) -> void:
	var preset: int = _transition_map.get(name, UIFlowTransitionType.Type.NONE)
	UIFlow.push(TransitionDemoPage, {
		"transition_name": name,
		"enter_preset": preset,
		"enter_duration": 0.3,
	})


func _on_back() -> void:
	UIFlow.pop()
