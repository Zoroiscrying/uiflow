## Title screen — entry point, fades into main menu.
class_name TitleScreen extends UIFlowPage

func _on_opened(_data: Dictionary = {}) -> void:
	# Animate title appearance
	$Title.modulate.a = 0.0
	UIFlow.animate($Title, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.8)

	# Auto-navigate to main menu after a short delay
	get_tree().create_timer(1.5).timeout.connect(func():
		UIFlow.push(MainMenuScreen, {})
	)
