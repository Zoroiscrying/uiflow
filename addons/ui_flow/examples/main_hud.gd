## Main HUD — always visible, shows device-aware icon prompts and handles Esc.
class_name MainHUD extends UIFlowPage

var _nearby_interactive: Node = null
var _device_connected: bool = false

@onready var _prompt_bar: HBoxContainer = $PromptBar/Margin/HBox
@onready var _prompt_container: PanelContainer = $PromptBar


func _on_created(_data: Variant = null) -> void:
	allow_world_input = true


func _on_opened(_data: Variant = null) -> void:
	_connect_device()
	_update_prompts()


func _on_closed() -> void:
	_disconnect_device()


## Called by interactive objects when player enters/exits range.
func set_nearby_interactive(object: Node) -> void:
	_nearby_interactive = object
	_update_prompts()


func _connect_device() -> void:
	if _device_connected:
		return
	if UIFlow.InputDevice == null:
		return
	if not UIFlow.InputDevice.device_changed.is_connected(_on_device_changed):
		UIFlow.InputDevice.device_changed.connect(_on_device_changed)
	_device_connected = true


func _disconnect_device() -> void:
	if not _device_connected or UIFlow.InputDevice == null:
		return
	if UIFlow.InputDevice.device_changed.is_connected(_on_device_changed):
		UIFlow.InputDevice.device_changed.disconnect(_on_device_changed)
	_device_connected = false


func _on_device_changed(_kind: UIFlowInputDevice.Kind) -> void:
	_update_prompts()


func _update_prompts() -> void:
	for child in _prompt_bar.get_children():
		child.queue_free()

	if _nearby_interactive == null:
		_prompt_container.visible = false
		return

	_prompt_container.visible = true
	_prompt_bar.add_child(UIFlowInputPrompt.make_semantic(&"pause", "Pause", Color(0.85, 0.35, 0.3)))

	if _nearby_interactive.has_method("get_interaction_prompts"):
		for prompt in _nearby_interactive.get_interaction_prompts():
			_add_prompt_entry(prompt)
	else:
		_prompt_bar.add_child(UIFlowInputPrompt.make_semantic(&"interact", "Interact", Color(0.25, 0.7, 0.35)))


func _add_prompt_entry(prompt: Variant) -> void:
	if prompt is Dictionary:
		var d: Dictionary = prompt
		var semantic: StringName = d.get("semantic", &"interact")
		var label: String = str(d.get("label", "Interact"))
		var color: Color = d.get("color", Color(0.25, 0.7, 0.35))
		_prompt_bar.add_child(UIFlowInputPrompt.make_semantic(semantic, label, color))
		return
	# Legacy plain string — show as label-only chip with a generic badge.
	var chip := UIFlowInputPrompt.make("?", str(prompt), Color(0.45, 0.5, 0.55))
	_prompt_bar.add_child(chip)


## When MainHUD is topmost and Esc is pressed, show a pause/return prompt.
func _on_back() -> void:
	UIFlowUI.Confirm.show_confirm(
		"Paused",
		"Return to Demo Hub?",
		func():
			var tree := get_tree()
			UIFlow.pop()
			tree.change_scene_to_file("res://addons/ui_flow/examples/main.tscn")
	,
		Callable()
	)
