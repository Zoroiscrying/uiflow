## Dialog page — NPC dialog, opened by interacting with NPC in 3D world.
class_name DialogPage extends UIFlowPage

var _dialog_text: String = "Hello, traveler! Welcome to our village."


func _on_opened(data: Dictionary = {}) -> void:
	if data.has("text"):
		_dialog_text = data["text"]
	if data.has("speaker"):
		$DialogBox/VBox/Speaker.text = data["speaker"]

	$DialogBox/VBox/Text.text = _dialog_text
	$Dimmer.modulate.a = 0.0
	$DialogBox.modulate.a = 0.0

	var tween = create_tween().set_parallel(true)
	tween.tween_property($Dimmer, "modulate:a", 0.3, 0.15)
	tween.tween_property($DialogBox, "modulate:a", 1.0, 0.2)


## Esc or Enter both close the dialog.
func _on_back() -> void:
	UIFlow.pop()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		UIFlow.pop()
		get_viewport().set_input_as_handled()
