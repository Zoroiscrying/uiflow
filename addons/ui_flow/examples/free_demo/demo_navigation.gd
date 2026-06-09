## Navigation Demo — push/pop/replace with transitions.
class_name UIFlowDemoNavigation extends UIFlowPage

@onready var _back_button: Button = $Panel/VBox/BackButton
@onready var _push_button: Button = $Panel/VBox/PushButton
@onready var _stack_label: Label = $Panel/VBox/StackLabel


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())
	_push_button.pressed.connect(func():
		UIFlow.push(get_script())  # Push another instance of this page
	)


func _on_opened(_data: Variant = null) -> void:
	_stack_label.text = "Stack depth: %d" % UIFlow.stack_depth()
	UIFlow.set_default_focus(_push_button)


func _on_shown() -> void:
	_stack_label.text = "Stack depth: %d" % UIFlow.stack_depth()
