## Standalone Gamepad UI demo page — directional focus + virtual cursor showcase.
class_name GamepadDemoPage extends UIFlowPage

const ITEMS: Array[Dictionary] = [
	{"icon": "SWD", "name": "Iron Sword", "desc": "ATK +12. A reliable blade."},
	{"icon": "SHD", "name": "Kite Shield", "desc": "DEF +8. Blocks frontal blows."},
	{"icon": "POT", "name": "Health Potion", "desc": "Restores 50 HP over 5s."},
	{"icon": "BOW", "name": "Hunter Bow", "desc": "ATK +9. Fires in an arc."},
	{"icon": "RNG", "name": "Swift Ring", "desc": "SPD +10%. Light as air."},
	{"icon": "ARM", "name": "Plate Armor", "desc": "DEF +15. Heavy but sturdy."},
	{"icon": "BOT", "name": "Scout Boots", "desc": "SPD +5%. Silent steps."},
	{"icon": "GEM", "name": "Mana Gem", "desc": "MP +30. Glows faintly."},
	{"icon": "KEY", "name": "Rusty Key", "desc": "Opens an old cellar door."},
	{"icon": "MAP", "name": "Torn Map", "desc": "Marks a cave to the north."},
]

@onready var _menu_vbox: VBoxContainer = $BG/Panel/VBox/Body/MenuPanel/MenuVBox
@onready var _grid: GridContainer = $BG/Panel/VBox/Body/GridPanel/Grid
@onready var _item_name: Label = $BG/Panel/VBox/Body/DetailPanel/DetailVBox/ItemName
@onready var _item_desc: Label = $BG/Panel/VBox/Body/DetailPanel/DetailVBox/ItemDesc
@onready var _focus_label: Label = $BG/Panel/VBox/TopBar/FocusLabel
@onready var _wrap_check: CheckBox = $BG/Panel/VBox/BottomBar/WrapCheck
@onready var _cursor_button: Button = $BG/Panel/VBox/BottomBar/CursorButton
@onready var _bottom_bar: HBoxContainer = $BG/Panel/VBox/BottomBar
@onready var _bg: ColorRect = $BG

var _prev_wrap := false
var _last_focus: Control = null
var _prompt_row: HBoxContainer
var _first_menu_button: Button = null
var _menu_buttons: Array[Button] = []
var _grid_buttons: Array[Button] = []


func _ready() -> void:
	# Let clicks fall through empty chrome; children still receive input.
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_menu()
	_build_grid()
	_wire_focus_neighbors()
	_build_prompt_row()
	_prev_wrap = UIFlow.Config.focus_wrap_enabled
	_wrap_check.button_pressed = _prev_wrap
	_wrap_check.toggled.connect(func(on: bool):
		UIFlow.Config.focus_wrap_enabled = on
	)
	_cursor_button.pressed.connect(_toggle_cursor)
	# Prefer path-based auto-focus after enter animation.
	if _first_menu_button:
		default_focus_path = get_path_to(_first_menu_button)


func _build_prompt_row() -> void:
	_prompt_row = HBoxContainer.new()
	_prompt_row.name = "PromptRow"
	_prompt_row.add_theme_constant_override("separation", 16)
	var vbox: VBoxContainer = $BG/Panel/VBox
	var bottom_idx: int = _bottom_bar.get_index()
	vbox.add_child(_prompt_row)
	vbox.move_child(_prompt_row, bottom_idx)

	_prompt_row.add_child(UIFlowInputPrompt.make_semantic(&"accept", "Confirm", Color(0.2, 0.72, 0.32)))
	_prompt_row.add_child(UIFlowInputPrompt.make_semantic(&"cancel", "Back", Color(0.85, 0.25, 0.25)))
	_prompt_row.add_child(UIFlowInputPrompt.make_semantic(&"dpad", "Focus", Color(0.35, 0.45, 0.7)))
	_prompt_row.add_child(UIFlowInputPrompt.make_semantic(&"stick", "Cursor when ON", Color(0.55, 0.55, 0.6)))
	_prompt_row.add_child(UIFlowInputPrompt.make_semantic(&"f1", "Code overlay", Color(0.35, 0.5, 0.75)))
	if UIFlow.InputDevice != null and not UIFlow.InputDevice.device_changed.is_connected(_on_prompt_device_changed):
		UIFlow.InputDevice.device_changed.connect(_on_prompt_device_changed)


func _on_prompt_device_changed(_kind: UIFlowInputDevice.Kind) -> void:
	if _prompt_row == null:
		return
	for child in _prompt_row.get_children():
		if child is UIFlowInputPrompt:
			(child as UIFlowInputPrompt).refresh_for_device()


func _on_opened(_data: Variant = null) -> void:
	_update_cursor_button()


func _on_after_opened() -> void:
	_ensure_menu_focus()


func _on_shown() -> void:
	_update_cursor_button()
	call_deferred("_ensure_menu_focus")


func _input(event: InputEvent) -> void:
	# If nothing is focused, first Accept focuses the menu so A can activate next.
	if event.is_action_pressed(&"ui_accept") and not event.is_echo():
		var owner := get_viewport().gui_get_focus_owner()
		if owner == null or not is_ancestor_of(owner):
			_ensure_menu_focus()
			get_viewport().set_input_as_handled()


func _on_before_closed() -> void:
	UIFlow.Config.focus_wrap_enabled = _prev_wrap
	UIFlow.Cursor.disable()
	if UIFlow.InputDevice != null and UIFlow.InputDevice.device_changed.is_connected(_on_prompt_device_changed):
		UIFlow.InputDevice.device_changed.disconnect(_on_prompt_device_changed)


func _on_back() -> void:
	_quit_to_hub()


func _ensure_menu_focus() -> void:
	if UIFlow.Cursor != null and UIFlow.Cursor.is_enabled():
		return
	var owner := get_viewport().gui_get_focus_owner()
	if owner != null and is_ancestor_of(owner):
		return
	if _first_menu_button != null and is_instance_valid(_first_menu_button):
		_first_menu_button.grab_focus()
		UIFlow.set_default_focus(_first_menu_button)


func _process(_delta: float) -> void:
	var owner := get_viewport().gui_get_focus_owner()
	if owner == _last_focus:
		return
	_last_focus = owner
	_focus_label.text = "Focus: %s" % (owner.name if owner != null else "-")


func _build_menu() -> void:
	_menu_buttons.clear()
	var entries: Array[Array] = [
		["Continue", func(): _flash("Continue pressed")],
		["Options", func(): _flash("Options pressed")],
		["Inventory", func(): _flash("Inventory pressed — try the grid!")],
		["Quit to Demo Hub", _quit_to_hub],
	]
	for entry: Array in entries:
		var b := Button.new()
		b.name = "Menu%s" % entry[0].replace(" ", "")
		b.text = entry[0]
		b.focus_mode = Control.FOCUS_ALL
		b.custom_minimum_size = Vector2(180, 44)
		b.pressed.connect(entry[1])
		_menu_vbox.add_child(b)
		_menu_buttons.append(b)
		if _first_menu_button == null:
			_first_menu_button = b


func _build_grid() -> void:
	_grid_buttons.clear()
	for i in 15:
		var item: Dictionary = ITEMS[i % ITEMS.size()]
		var b := Button.new()
		b.name = "Slot%d" % i
		b.text = "%s\n%d" % [item["icon"], i]
		b.focus_mode = Control.FOCUS_ALL
		b.custom_minimum_size = Vector2(110, 64)
		if i == 7:
			b.disabled = true
		b.focus_entered.connect(_show_item.bind(item))
		b.pressed.connect(func(): _flash("Used: %s" % item["name"]))
		_grid.add_child(b)
		_grid_buttons.append(b)


## Explicit neighbors so focus works even if geometry guesses fail across panels.
func _wire_focus_neighbors() -> void:
	for i in _menu_buttons.size():
		var b := _menu_buttons[i]
		if i > 0:
			b.focus_neighbor_top = b.get_path_to(_menu_buttons[i - 1])
		if i < _menu_buttons.size() - 1:
			b.focus_neighbor_bottom = b.get_path_to(_menu_buttons[i + 1])
		if not _grid_buttons.is_empty():
			b.focus_neighbor_right = b.get_path_to(_grid_buttons[0])

	var cols := _grid.columns
	for i in _grid_buttons.size():
		var b := _grid_buttons[i]
		var col := i % cols
		var row := i / cols
		if col > 0:
			b.focus_neighbor_left = b.get_path_to(_grid_buttons[i - 1])
		elif not _menu_buttons.is_empty():
			var menu_idx: int = mini(row, _menu_buttons.size() - 1)
			b.focus_neighbor_left = b.get_path_to(_menu_buttons[menu_idx])
		if col < cols - 1 and i + 1 < _grid_buttons.size():
			b.focus_neighbor_right = b.get_path_to(_grid_buttons[i + 1])
		if row > 0:
			b.focus_neighbor_top = b.get_path_to(_grid_buttons[i - cols])
		if i + cols < _grid_buttons.size():
			b.focus_neighbor_bottom = b.get_path_to(_grid_buttons[i + cols])


func _show_item(item: Dictionary) -> void:
	_item_name.text = item["name"]
	_item_desc.text = item["desc"]


func _flash(msg: String) -> void:
	_item_name.text = msg
	_item_desc.text = ""


func _toggle_cursor() -> void:
	if UIFlow.Cursor.is_enabled():
		UIFlow.Cursor.disable()
		call_deferred("_ensure_menu_focus")
	else:
		UIFlow.Cursor.enable()
	_update_cursor_button()


func _update_cursor_button() -> void:
	var on := UIFlow.Cursor.is_enabled()
	_cursor_button.text = "Virtual Cursor: ON" if on else "Virtual Cursor: OFF"
	if on:
		_item_desc.text = "Cursor ON: left stick moves the pointer; A clicks under the cursor. D-Pad/arrows still move focus. B = back."
	else:
		_item_desc.text = "Cursor OFF: left stick / D-Pad / arrows move focus; A/Enter/Space activates (ui_accept). B/Esc = back (ui_cancel)."


func _quit_to_hub() -> void:
	UIFlow.Config.focus_wrap_enabled = _prev_wrap
	UIFlow.Cursor.disable()
	# Prefer stack pop when opened via UIFlow.push from the Free Demo hub.
	if UIFlow.stack_depth() > 1:
		UIFlow.pop()
		return
	var tree := get_tree()
	UIFlow.pop()
	tree.change_scene_to_file("res://addons/ui_flow/examples/main.tscn")
