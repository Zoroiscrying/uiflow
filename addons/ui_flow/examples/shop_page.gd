## Shop page — opened by interacting with shop object in 3D world.
## Transitions configured in Inspector (fade + scale).
class_name ShopPage extends UIFlowPage

@onready var _close_button: Button = $Panel/VBox/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(_on_close_pressed)


func _on_close_pressed() -> void:
	UIFlow.pop()


func _on_back() -> void:
	UIFlow.pop()


func _on_opened(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus(_close_button)
