## SurvivorsPausePage — pause menu with resume and quit.
class_name SurvivorsPausePage extends UIFlowPage

@onready var _resume_button: Button = $Dimmer/VBox/ResumeButton
@onready var _quit_button: Button = $Dimmer/VBox/QuitButton


func _ready() -> void:
	is_modal = true
	_resume_button.pressed.connect(func(): UIFlow.pop())
	_quit_button.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Quit?", "Return to main menu?", func():
			get_tree().paused = false
			UIFlow.pop_to_root()
		)
	)


func _on_opened(_data: Variant = null) -> void:
	get_tree().paused = true
	UIFlow.set_default_focus(_resume_button)


func _on_closed() -> void:
	get_tree().paused = false
