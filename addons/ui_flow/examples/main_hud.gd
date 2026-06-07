## Main HUD - shows hint text, opens ExampleHub on Esc.
class_name MainHUD extends UIFlowPage

var _examples_open: bool = false


func _on_opened(_data: Dictionary = {}) -> void:
	_examples_open = false
	$HintPanel.visible = true


func _on_shown() -> void:
	_examples_open = false
	$HintPanel.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _examples_open:
		_examples_open = true
		$HintPanel.visible = false
		UIFlow.push(ExampleHub, {}, UIFlowTransitionType.Type.FADE)
		get_viewport().set_input_as_handled()
