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

var _prev_wrap := false
var _last_focus: Control = null


func _ready() -> void:
	_build_menu()
	_build_grid()
	_prev_wrap = UIFlow.Config.focus_wrap_enabled
	_wrap_check.button_pressed = _prev_wrap
	_wrap_check.toggled.connect(func(on: bool):
		UIFlow.Config.focus_wrap_enabled = on
	)
	_cursor_button.pressed.connect(_toggle_cursor)


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_menu_vbox.get_child(0) as Button)
	_update_cursor_button()


func _on_shown() -> void:
	_update_cursor_button()


func _on_before_closed() -> void:
	# Leave global state the way we found it.
	UIFlow.Config.focus_wrap_enabled = _prev_wrap
	UIFlow.Cursor.disable()


func _on_back() -> void:
	_quit_to_hub()


func _process(_delta: float) -> void:
	var owner := get_viewport().gui_get_focus_owner()
	if owner == _last_focus:
		return
	_last_focus = owner
	_focus_label.text = "Focus: %s" % (owner.name if owner != null else "-")


func _build_menu() -> void:
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
		b.custom_minimum_size = Vector2(180, 44)
		b.pressed.connect(entry[1])
		_menu_vbox.add_child(b)


func _build_grid() -> void:
	for i in 15:
		var item: Dictionary = ITEMS[i % ITEMS.size()]
		var b := Button.new()
		b.name = "Slot%d" % i
		b.text = "%s\n%d" % [item["icon"], i]
		b.custom_minimum_size = Vector2(110, 64)
		if i == 7:
			b.disabled = true  # demos focus skipping disabled controls
		b.focus_entered.connect(_show_item.bind(item))
		b.pressed.connect(func(): _flash("Used: %s" % item["name"]))
		_grid.add_child(b)


func _show_item(item: Dictionary) -> void:
	_item_name.text = item["name"]
	_item_desc.text = item["desc"]


func _flash(msg: String) -> void:
	_item_name.text = msg
	_item_desc.text = ""


func _toggle_cursor() -> void:
	if UIFlow.Cursor.is_enabled():
		UIFlow.Cursor.disable()
	else:
		UIFlow.Cursor.enable()
	_update_cursor_button()


func _update_cursor_button() -> void:
	_cursor_button.text = "Virtual Cursor: ON" if UIFlow.Cursor.is_enabled() else "Virtual Cursor: OFF"


func _quit_to_hub() -> void:
	UIFlow.Config.focus_wrap_enabled = _prev_wrap
	UIFlow.Cursor.disable()
	var tree := get_tree()
	UIFlow.pop()
	tree.change_scene_to_file("res://addons/ui_flow/examples/main.tscn")
