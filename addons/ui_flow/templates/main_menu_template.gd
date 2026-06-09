## Main Menu Template — customizable main menu page.
##
## Copy this and the .tscn to your UIScene/ directory.
## Change the title, buttons, and connect your own logic.
class_name MainMenuTemplate extends UIFlowPage

@onready var play_button: Button = $Center/PlayButton
@onready var settings_button: Button = $Center/SettingsButton
@onready var quit_button: Button = $Center/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)


func _on_play() -> void:
	# Replace with your game start logic
	print("Play pressed!")


func _on_settings() -> void:
	# Navigate to settings page
	# UIFlow.push(SettingsPage)
	pass


func _on_quit() -> void:
	UIFlowUI.Confirm.show_confirm("Quit", "Are you sure?",
		func(): get_tree().quit()
	)


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(play_button)
