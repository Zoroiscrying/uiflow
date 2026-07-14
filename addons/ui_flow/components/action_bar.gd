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


func _exit_tree() -> void:
	if _uiflow:
		if _uiflow.page_opened.is_connected(_on_stack_changed):
			_uiflow.page_opened.disconnect(_on_stack_changed)
		if _uiflow.page_closed.is_connected(_on_stack_changed):
			_uiflow.page_closed.disconnect(_on_stack_changed)
	_unbind_page()


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


## Build one icon/key + label chip for an action.
func _create_chip(action: UIInputActionNode) -> Control:
	var chip := HBoxContainer.new()
	chip.add_theme_constant_override("separation", 6)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if action.icon:
		var icon_rect := TextureRect.new()
		icon_rect.texture = action.icon
		icon_rect.custom_minimum_size = icon_size
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(icon_rect)
	elif not action.godot_action.is_empty():
		var key_label := Label.new()
		key_label.text = "[%s]" % _get_action_key_text(action.godot_action)
		key_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
		key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(key_label)

	var label_node := Label.new()
	label_node.text = action.label if not action.label.is_empty() else String(action.action_name)
	label_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(label_node)

	if not action.enabled:
		chip.modulate = disabled_modulate
	return chip


## Resolve a Godot input action to a short human-readable key/button text.
func _get_action_key_text(godot_action: StringName) -> String:
	for event in InputMap.action_get_events(godot_action):
		if event is InputEventKey:
			var keycode: Key = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			return OS.get_keycode_string(keycode)
		if event is InputEventJoypadButton:
			return "Pad %d" % event.button_index
		if event is InputEventMouseButton:
			return "Mouse %d" % event.button_index
	return String(godot_action)
