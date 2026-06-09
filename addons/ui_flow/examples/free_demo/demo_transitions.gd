## Transitions Demo — shows all available transition effects.
class_name UIFlowDemoTransitions extends UIFlowPage

@onready var _back_button: Button = $Panel/VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())

	# Connect transition buttons
	var buttons_node := $Panel/VBox/TransButtons
	for i in range(buttons_node.get_child_count()):
		var btn: Button = buttons_node.get_child(i)
		btn.pressed.connect(func(): _show_transition(btn.text))


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus($Panel/VBox/TransButtons.get_child(0) as Button)


func _show_transition(name: String) -> void:
	UIFlowUI.Toast.show_toast("Transition: %s" % name, "info", 1.5)


func _on_back() -> void:
	UIFlow.pop()
