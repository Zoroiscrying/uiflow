## Theme Demo — switch between built-in themes.
class_name UIFlowDemoTheme extends UIFlowPage

@onready var _back_button: Button = $Panel/VBox/BackButton
@onready var _current_label: Label = $Panel/VBox/CurrentLabel


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())

	$Panel/VBox/ThemeButtons/DarkBtn.pressed.connect(func():
		UIFlow.apply_builtin_theme("dark")
		_current_label.text = "Current: Dark"
	)
	$Panel/VBox/ThemeButtons/LightBtn.pressed.connect(func():
		UIFlow.apply_builtin_theme("light")
		_current_label.text = "Current: Light"
	)


func _on_opened(_data: Variant = null) -> void:
	var theme := UIFlow.get_theme()
	if theme:
		_current_label.text = "Current: Custom"
	UIFlow.set_default_focus($Panel/VBox/ThemeButtons/DarkBtn)


func _on_back() -> void:
	UIFlow.pop()
