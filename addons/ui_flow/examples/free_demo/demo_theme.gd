## Theme Demo — switch between native Godot themes.
class_name UIFlowDemoTheme extends UIFlowPage

const THEMES: Dictionary = {
	"Dark": "res://addons/ui_flow/themes/godot/dark.tres",
	"Light": "res://addons/ui_flow/themes/godot/light.tres",
	"Ocean": "res://addons/ui_flow/themes/godot/ocean.tres",
	"Forest": "res://addons/ui_flow/themes/godot/forest.tres",
	"High Contrast": "res://addons/ui_flow/themes/godot/high_contrast.tres",
	"Warm": "res://addons/ui_flow/themes/godot/warm.tres",
}

@onready var _back_button: Button = $Panel/VBox/BackButton
@onready var _current_label: Label = $Panel/VBox/CurrentLabel
@onready var _theme_buttons: HBoxContainer = $Panel/VBox/ThemeButtons


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())

	for btn in _theme_buttons.get_children():
		if btn is Button:
			var name: String = btn.text
			btn.pressed.connect(func():
				var path: String = THEMES.get(name, "")
				if not path.is_empty():
					UIFlow.apply_godot_theme(load(path) as Theme)
				_current_label.text = "Current: %s" % name
			)


func _on_opened(_data: Variant = null) -> void:
	var theme: Theme = UIFlow.get_godot_theme()
	if theme != null:
		_current_label.text = "Current: %s" % theme.resource_path.get_file()
	UIFlow.set_default_focus(_theme_buttons.get_child(0) as Button)


func _on_back() -> void:
	UIFlow.pop()
