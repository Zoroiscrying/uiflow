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
	for i in range(_examples.size()):
		var btn: Button = $Margin/Scroll/VBox/Buttons.get_child(i)
		var example: Dictionary = _examples[i]
		btn.text = example["title"]
		btn.pressed.connect(func():
			UIFlow.push(example["page_class"], {}, UIFlowTransitionType.Type.FADE)
		)

	$Margin/Scroll/VBox/QuitButton.pressed.connect(func():
		UIFlowUI.Confirm.show("Quit", "Exit the example viewer?",
			func(): get_tree().quit()
		)
	)


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus($Margin/Scroll/VBox/Buttons.get_child(0))


func _on_resume() -> void:
	UIFlow.set_default_focus($Margin/Scroll/VBox/Buttons.get_child(0))
