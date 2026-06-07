## Example Hub — main entry point for all UIFlow examples.
##
## Demonstrates UIFlow navigation between example scenes.
class_name ExampleHub extends UIFlowPage

## Maps example titles to their wrapper data.
var _examples: Array[Dictionary] = [
	{"title": "Main Menu Flow", "page_class": MainMenuScreen},
	{"title": "Settings Screen", "page_class": SettingsPageExample},
	{"title": "RPG HUD + Pause", "page_class": RPGHudSetupPage},
	{"title": "Component Gallery", "page_class": GalleryPage},
]


func _ready() -> void:
	var buttons_node := $Margin/Scroll/VBox/Buttons
	for i in range(_examples.size()):
		# Scene has Button, Label, Button, Label... so button index = i * 2
		var btn: Button = buttons_node.get_child(i * 2)
		var example: Dictionary = _examples[i]
		btn.text = example["title"]
		btn.pressed.connect(func():
			# overlay=true: ExampleHub stays visible behind the sub-page
			UIFlow.push(example["page_class"], {}, UIFlowTransitionType.Type.FADE, null, true)
		)

	$Margin/Scroll/VBox/QuitButton.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Quit", "Exit the example viewer?",
			func(): get_tree().quit()
		)
	)


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus($Margin/Scroll/VBox/Buttons.get_child(0) as Button)


func _on_resume() -> void:
	UIFlow.set_default_focus($Margin/Scroll/VBox/Buttons.get_child(0) as Button)
