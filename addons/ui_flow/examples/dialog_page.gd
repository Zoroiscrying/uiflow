## Dialog page — NPC dialog, opened by interacting with NPC in 3D world.
## Transitions configured in Inspector (fade).
class_name DialogPage extends UIFlowPage

var _dialog_text: String = "Hello, traveler! Welcome to our village."


func _on_opened(data: Dictionary = {}) -> void:
	if data.has("text"):
		_dialog_text = data["text"]
	if data.has("speaker"):
		$DialogBox/VBox/Speaker.text = data["speaker"]
	$DialogBox/VBox/Text.text = _dialog_text


func _on_back() -> void:
	UIFlow.pop()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		UIFlow.pop()
		var vp := get_viewport()
		if vp:
			vp.set_input_as_handled()
