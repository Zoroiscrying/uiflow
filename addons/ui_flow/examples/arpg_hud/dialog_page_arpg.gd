## ARPG Dialog Page — displays NPC dialog with line-by-line progression.
class_name ARPGDialogPage extends UIFlowPage

@onready var _name_label: Label = $Panel/VBox/NameLabel
@onready var _text_label: RichTextLabel = $Panel/VBox/TextLabel
@onready var _portrait_rect: TextureRect = $Panel/VBox/HBox/Portrait
@onready var _continue_hint: Label = $Panel/VBox/ContinueHint
@onready var _options_container: VBoxContainer = $Panel/VBox/OptionsContainer

var _dialog: DialogData
var _current_line: int = 0
var _on_complete: Callable


func _ready() -> void:
	is_modal = true
	_options_container.visible = false


func _on_opened(data: Dictionary = {}) -> void:
	_dialog = data.get("dialog", null)
	_on_complete = data.get("on_complete", Callable())
	_current_line = 0

	if _dialog:
		_name_label.text = _dialog.npc_name
		if _dialog.portrait:
			_portrait_rect.texture = _dialog.portrait
		_show_current_line()


func _show_current_line() -> void:
	if _dialog == null or _current_line >= _dialog.lines.size():
		_close_dialog()
		return

	var line: Dictionary = _dialog.lines[_current_line]
	_text_label.text = line.get("text", "")
	_continue_hint.text = "[Enter] Continue" if not line.has("options") else "Choose an option"

	if line.has("options"):
		_show_options(line["options"])
	else:
		_options_container.visible = false


func _show_options(options: Array) -> void:
	_options_container.visible = true
	UIFlowUtils.ClearChildren(_options_container)

	for option in options:
		var btn := Button.new()
		btn.text = option.get("text", "...")
		btn.custom_minimum_size = Vector2(200, 36)
		btn.pressed.connect(func():
			var callback: Callable = option.get("callback", Callable())
			if callback.is_valid():
				callback.call()
			_current_line += 1
			_show_current_line()
		)
		_options_container.add_child(btn)

	# Focus first option
	if _options_container.get_child_count() > 0:
		UIFlow.set_default_focus(_options_container.get_child(0) as Button)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _options_container.visible:
			return  # Don't advance if options are shown
		_current_line += 1
		_show_current_line()
		get_viewport().set_input_as_handled()


func _close_dialog() -> void:
	if _on_complete.is_valid():
		_on_complete.call()
	UIFlow.pop()


func _on_back() -> void:
	_close_dialog()
