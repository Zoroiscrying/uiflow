## Main HUD — always visible, shows prompts and handles Esc.
class_name MainHUD extends UIFlowPage

var _nearby_interactive: Node = null

@onready var _prompt_bar: HBoxContainer = $PromptBar/Margin/HBox
@onready var _prompt_container: PanelContainer = $PromptBar


func _on_created(_data: Variant = null) -> void:
	_prompt_container.visible = false


func _on_opened(_data: Variant = null) -> void:
	_update_prompts()


## Called by interactive objects when player enters/exits range.
func set_nearby_interactive(object: Node) -> void:
	_nearby_interactive = object
	_update_prompts()


func _update_prompts() -> void:
	for child in _prompt_bar.get_children():
		child.queue_free()

	if _nearby_interactive == null:
		_prompt_container.visible = false
		return

	_prompt_container.visible = true
	_add_prompt("[Esc] Pause")

	if _nearby_interactive.has_method("get_interaction_prompts"):
		for prompt in _nearby_interactive.get_interaction_prompts():
			_add_prompt(prompt)


func _add_prompt(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	_prompt_bar.add_child(label)


## When MainHUD is topmost and Esc is pressed, open Pause menu.
func _on_back() -> void:
	pass
