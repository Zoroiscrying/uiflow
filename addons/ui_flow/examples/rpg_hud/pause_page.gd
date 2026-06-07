## Pause menu — modal overlay with Resume/Settings/Quit.
## Button connections via Inspector signals.
class_name PausePage extends UIFlowPage


func _on_resume_pressed() -> void:
	UIFlow.pop()


func _on_settings_pressed() -> void:
	UIFlow.push(SettingsPageExample, {}, UIFlowTransitionType.Type.SLIDE_LEFT)


func _on_quit_pressed() -> void:
	UIFlowUI.Confirm.show_confirm("Quit", "Return to main menu?",
		func(): UIFlow.pop_to_root()
	)


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus($Panel/VBox/ResumeButton)

	# Animate panel appearance
	$Dimmer.modulate.a = 0.0
	$Panel.scale = Vector2(0.9, 0.9)
	$Panel.modulate.a = 0.0

	var tween = create_tween().set_parallel(true)
	tween.tween_property($Dimmer, "modulate:a", 0.5, 0.15)
	tween.tween_property($Panel, "modulate:a", 1.0, 0.15)
	tween.tween_property($Panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_resume() -> void:
	UIFlow.set_default_focus($Panel/VBox/ResumeButton)
