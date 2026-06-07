## Main menu - central hub with navigation to other screens.
class_name MainMenuScreen extends UIFlowPage

@onready var _play_button: Button = $Center/PlayButton
@onready var _settings_button: Button = $Center/SettingsButton
@onready var _credits_button: Button = $Center/CreditsButton
@onready var _quit_button: Button = $Center/QuitButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_credits_button.pressed.connect(_on_credits_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	print("Play pressed!")


func _on_settings_pressed() -> void:
	print("MainMenuScreen: Settings pressed!")
	var page = UIFlow.push(SettingsMenuScreen, {}, UIFlowTransitionType.Type.FADE)
	print("MainMenuScreen: push result = ", page)


func _on_credits_pressed() -> void:
	UIFlow.push(CreditsScreen, {}, UIFlowTransitionType.Type.FADE)


func _on_quit_pressed() -> void:
	UIFlowUI.Confirm.show_confirm("Quit", "Are you sure you want to quit?",
		func(): get_tree().quit()
	)


func _on_opened(_data: Dictionary = {}) -> void:
	# Stagger fade-in for menu buttons
	for i in range($Center.get_child_count()):
		$Center.get_child(i).modulate.a = 0.0

	var seq = UIFlow.sequencer()
	for i in range($Center.get_child_count()):
		var child = $Center.get_child(i)
		seq.add(child, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.15).delay(0.06 * i)
	seq.play()

	UIFlow.set_default_focus(_play_button)


func _on_shown() -> void:
	UIFlow.set_default_focus(_play_button)
