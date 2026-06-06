## Main menu — central hub with navigation to other screens.
extends UIFlowPage

func _ready() -> void:
	$VBox/PlayButton.pressed.connect(func(): print("Play pressed!"))
	$VBox/SettingsButton.pressed.connect(func():
		UIFlow.push(SettingsMenuScreen, {}, UIFlowTransitionType.Type.SLIDE_LEFT)
	)
	$VBox/CreditsButton.pressed.connect(func():
		UIFlow.push(CreditsScreen, {}, UIFlowTransitionType.Type.FADE)
	)
	$VBox/QuitButton.pressed.connect(func():
		UIFlowUI.Confirm.show("Quit", "Are you sure you want to quit?",
			func(): get_tree().quit()
		)
	)


func _on_enter(_data: Dictionary = {}) -> void:
	# Stagger animation for menu buttons
	var seq = UIFlow.sequencer()
	for i in range($VBox.get_child_count()):
		var child = $VBox.get_child(i)
		child.modulate.a = 0.0
		seq.add(child, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.2).delay(0.05 * i)
	seq.play()

	# Focus first button
	UIFlow.set_default_focus($VBox/PlayButton)


func _on_resume() -> void:
	# Re-focus when returning from sub-screens
	UIFlow.set_default_focus($VBox/PlayButton)
