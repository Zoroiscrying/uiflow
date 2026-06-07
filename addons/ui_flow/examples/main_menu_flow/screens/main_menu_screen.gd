## Main menu — central hub with navigation to other screens.
## Button connections are in the .tscn scene (Inspector signals).
class_name MainMenuScreen extends UIFlowPage

var _stagger_done: bool = false


func _on_play_pressed() -> void:
	print("Play pressed!")


func _on_settings_pressed() -> void:
	UIFlow.push(SettingsMenuScreen, {}, UIFlowTransitionType.Type.NONE)


func _on_credits_pressed() -> void:
	UIFlow.push(CreditsScreen, {}, UIFlowTransitionType.Type.NONE)


func _on_quit_pressed() -> void:
	UIFlowUI.Confirm.show_confirm("Quit", "Are you sure you want to quit?",
		func(): get_tree().quit()
	)


func _on_enter(_data: Dictionary = {}) -> void:
	# Stagger fade-in for menu buttons
	for i in range($Center.get_child_count()):
		$Center.get_child(i).modulate.a = 0.0

	var seq = UIFlow.sequencer()
	for i in range($Center.get_child_count()):
		var child = $Center.get_child(i)
		seq.add(child, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.15).delay(0.06 * i)
	seq.play()

	UIFlow.set_default_focus($Center/PlayButton)


func _on_resume() -> void:
	UIFlow.set_default_focus($Center/PlayButton)
