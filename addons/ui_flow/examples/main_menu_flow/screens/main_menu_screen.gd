## Main menu — central hub with navigation to other screens.
class_name MainMenuScreen extends UIFlowPage

func _ready() -> void:
	$Center/PlayButton.pressed.connect(func(): print("Play pressed!"))
	$Center/SettingsButton.pressed.connect(func():
		UIFlow.push(SettingsMenuScreen, {}, UIFlowTransitionType.Type.SLIDE_LEFT)
	)
	$Center/CreditsButton.pressed.connect(func():
		UIFlow.push(CreditsScreen, {}, UIFlowTransitionType.Type.FADE)
	)
	$Center/QuitButton.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Quit", "Are you sure you want to quit?",
			func(): get_tree().quit()
		)
	)


func _on_enter(_data: Dictionary = {}) -> void:
	# Stagger fade-in for menu buttons
	# Set all children invisible FIRST (synchronous, no flash)
	for i in range($Center.get_child_count()):
		$Center.get_child(i).modulate.a = 0.0

	# Then animate them in one by one
	var seq = UIFlow.sequencer()
	for i in range($Center.get_child_count()):
		var child = $Center.get_child(i)
		seq.add(child, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.15).delay(0.06 * i)
	seq.play()

	UIFlow.set_default_focus($Center/PlayButton)


func _on_resume() -> void:
	# Re-focus when returning from sub-screens
	UIFlow.set_default_focus($Center/PlayButton)
