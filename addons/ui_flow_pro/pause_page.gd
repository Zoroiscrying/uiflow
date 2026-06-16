## SurvivorsPausePage — pause menu with resume and quit.
##
## UIFlow Features Demonstrated:
## - is_modal: Blocks input to pages below
## - process_mode = ALWAYS: Works while game is paused
## - get_tree().paused: Game pause/resume
## - UIFlowUI.Confirm: Confirmation dialog
## - UIFlow.pop_to_root(): Stack reset to root page
class_name SurvivorsPausePage extends UIFlowPage

@onready var _resume_button: Button = $Dimmer/VBox/ResumeButton
@onready var _quit_button: Button = $Dimmer/VBox/QuitButton
@onready var _title_label: Label = $Dimmer/VBox/TitleLabel


func _ready() -> void:
	is_modal = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume_button.pressed.connect(func(): UIFlow.pop())
	_quit_button.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm(
			SurvivorsLocalization.loc("quit_confirm_title"),
			SurvivorsLocalization.loc("quit_confirm_msg"),
			func():
				get_tree().paused = false
				UIFlow.pop_to_root()
		)
	)


func _on_opened(_data: Variant = null) -> void:
	get_tree().paused = true
	_update_language()
	SurvivorsLocalization.language_changed.connect(_update_language)
	UIFlow.set_default_focus(_resume_button)


func _on_closed() -> void:
	get_tree().paused = false
	if SurvivorsLocalization.language_changed.is_connected(_update_language):
		SurvivorsLocalization.language_changed.disconnect(_update_language)


func _update_language() -> void:
	_title_label.text = SurvivorsLocalization.loc("paused")
	_resume_button.text = SurvivorsLocalization.loc("resume")
	_quit_button.text = SurvivorsLocalization.loc("main_menu")
