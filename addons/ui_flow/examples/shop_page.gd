## Shop page — opened by interacting with shop object in 3D world.
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

	# Animate panel
	$Dimmer.modulate.a = 0.0
	$Panel.scale = Vector2(0.9, 0.9)
	$Panel.modulate.a = 0.0

	var tween = create_tween().set_parallel(true)
	tween.tween_property($Dimmer, "modulate:a", 0.5, 0.15)
	tween.tween_property($Panel, "modulate:a", 1.0, 0.15)
	tween.tween_property($Panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
