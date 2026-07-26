## UIFlowActionBar — input hint bar for the current top page.
##
## Renders the page's declarative UIInputActionNode entries as
## icon/key + label chips, similar to Unreal CommonUI's CommonBoundActionBar.
##
## In auto_bind mode (default) the bar listens to the UIFlow navigation stack
## and always shows the actions of the current top page. Without the UIFlow
## autoload (e.g. in unit tests) call bind_page() manually.
##
## [codeblock]
## var bar := UIFlowActionBar.new()
## add_child(bar)  # auto-binds to the top page
## bar.bind_page(my_page)  # or bind manually
## [/codeblock]
class_name UIFlowActionBar extends HBoxContainer

## Rebind automatically when the UIFlow navigation stack changes.
@export var auto_bind: bool = true

## Hide the whole bar when the bound page declares no (enabled) actions.
@export var hide_when_empty: bool = true

## Show disabled actions dimmed instead of hiding them.
@export var show_disabled: bool = false

## Size of action icons.
@export var icon_size: Vector2 = Vector2(20, 20)

## Modulate applied to chips of disabled actions (only with show_disabled).
@export var disabled_modulate: Color = Color(1, 1, 1, 0.35)

var _page: UIFlowPage = null
var _uiflow: Node = null  # UIFlow autoload, resolved lazily (null in tests)


func _ready() -> void:
	add_theme_constant_override("separation", 16)
	_uiflow = get_node_or_null("/root/UIFlow")
	if auto_bind and _uiflow:
		if not _uiflow.page_opened.is_connected(_on_stack_changed):
			_uiflow.page_opened.connect(_on_stack_changed)
		if not _uiflow.page_closed.is_connected(_on_stack_changed):
			_uiflow.page_closed.connect(_on_stack_changed)
		_rebind_top_page()
	if _uiflow != null and _uiflow.get("InputDevice") != null:
		var device: UIFlowInputDevice = _uiflow.InputDevice
		if not device.device_changed.is_connected(_on_device_changed):
			device.device_changed.connect(_on_device_changed)


func _exit_tree() -> void:
	if _uiflow:
		if _uiflow.page_opened.is_connected(_on_stack_changed):
			_uiflow.page_opened.disconnect(_on_stack_changed)
		if _uiflow.page_closed.is_connected(_on_stack_changed):
			_uiflow.page_closed.disconnect(_on_stack_changed)
		if _uiflow.get("InputDevice") != null:
			var device: UIFlowInputDevice = _uiflow.InputDevice
			if device.device_changed.is_connected(_on_device_changed):
				device.device_changed.disconnect(_on_device_changed)
	_unbind_page()


func _on_device_changed(_kind: UIFlowInputDevice.Kind) -> void:
	_rebuild()


## Bind the bar to a specific page. Pass null to clear.
func bind_page(page: UIFlowPage) -> void:
	_unbind_page()
	_page = page
	if _page:
		for action in _page.get_all_actions():
			if not action.enabled_changed.is_connected(_on_action_enabled_changed):
				action.enabled_changed.connect(_on_action_enabled_changed)
	_rebuild()


## Unbind from the current page and clear the bar.
func unbind() -> void:
	bind_page(null)


func _unbind_page() -> void:
	if _page:
		for action in _page.get_all_actions():
			if action.enabled_changed.is_connected(_on_action_enabled_changed):
				action.enabled_changed.disconnect(_on_action_enabled_changed)
	_page = null


func _on_stack_changed(_page_class: GDScript) -> void:
	_rebind_top_page()


func _rebind_top_page() -> void:
	if _uiflow == null:
		return
	var top_class: GDScript = _uiflow.current_page()
	if top_class == null:
		bind_page(null)
		return
	bind_page(_uiflow.get_page(top_class) as UIFlowPage)


func _on_action_enabled_changed(_value: bool) -> void:
	_rebuild()


func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var actions: Array = []
	if _page:
		actions = _page.get_all_actions() if show_disabled else _page.get_enabled_actions()

	visible = not (hide_when_empty and actions.is_empty())
	for action in actions:
		add_child(_create_chip(action))


## Build one device-aware icon/key + label chip for an action.
func _create_chip(action: UIInputActionNode) -> Control:
	var label: String = action.label if not action.label.is_empty() else String(action.action_name)
	var chip: UIFlowInputPrompt
	if action.icon != null:
		chip = UIFlowInputPrompt.make("?", label, Color(0.35, 0.55, 0.75), action.icon)
	elif not action.godot_action.is_empty():
		var semantic: StringName = UIFlowInputPromptIcons.semantic_for_action(action.godot_action)
		if not semantic.is_empty():
			chip = UIFlowInputPrompt.make_semantic(semantic, label, Color(0.35, 0.55, 0.75))
		else:
			chip = UIFlowInputPrompt.make(
				_get_action_key_text(action.godot_action),
				label,
				Color(0.35, 0.55, 0.75),
				UIFlowInputPromptIcons.texture_for_action(action.godot_action)
			)
	else:
		chip = UIFlowInputPrompt.make("?", label, Color(0.45, 0.5, 0.55))
	chip.icon_size = icon_size
	if not action.enabled:
		chip.modulate = disabled_modulate
	return chip


## Resolve a Godot input action to a short human-readable key/button text.
func _get_action_key_text(godot_action: StringName) -> String:
	var mapped: String = UIFlowInputPromptIcons.badge_for_action(godot_action)
	if mapped != String(godot_action):
		return mapped
	var prefer_pad: bool = UIFlow != null and UIFlow.InputDevice != null and UIFlow.InputDevice.is_gamepad()
	var pad_text := ""
	var key_text := ""
	for event in InputMap.action_get_events(godot_action):
		if event is InputEventKey and key_text.is_empty():
			var keycode: Key = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			key_text = OS.get_keycode_string(keycode)
		elif event is InputEventJoypadButton and pad_text.is_empty():
			pad_text = _joy_button_name((event as InputEventJoypadButton).button_index)
		elif event is InputEventMouseButton and key_text.is_empty():
			key_text = "Mouse %d" % (event as InputEventMouseButton).button_index
	if prefer_pad and not pad_text.is_empty():
		return pad_text
	if not key_text.is_empty():
		return key_text
	if not pad_text.is_empty():
		return pad_text
	return String(godot_action)


func _joy_button_name(button_index: int) -> String:
	match button_index:
		JOY_BUTTON_A:
			return "A"
		JOY_BUTTON_B:
			return "B"
		JOY_BUTTON_X:
			return "X"
		JOY_BUTTON_Y:
			return "Y"
		_:
			return "Pad %d" % button_index
