## UIFlowContextMenu — right-click context menu with nested submenus.
##
## Usage:
## [codeblock]
## var menu = UIFlowContextMenu.new()
## menu.add_item("Use", func(): use_item())
## menu.add_item("Drop", func(): drop_item())
## menu.add_separator()
## menu.add_submenu("More")
##     .add_item("Examine", func(): examine_item())
##     .add_item("Share", func(): share_item())
## menu.show_at(get_global_mouse_position())
## [/codeblock]
class_name UIFlowContextMenu extends PanelContainer

## Emitted when an item is selected.
signal item_selected(item_name: String)

## Emitted when menu is closed.
signal closed

var _items: Array[Dictionary] = []
var _vbox: VBoxContainer
var _submenu: UIFlowContextMenu
var _is_open: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	custom_minimum_size = Vector2(160, 0)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.16, 0.95)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(4)
	style.border_color = Color(0.25, 0.25, 0.3, 0.5)
	style.set_border_width_all(1)
	add_theme_stylebox_override("panel", style)

	_ensure_vbox()


## Lazily create the item container so add_item()/add_separator()/add_submenu()
## also work before the menu enters the tree (e.g. UIFlowContextMenu.new()).
func _ensure_vbox() -> void:
	if not is_instance_valid(self):
		return
	if _vbox == null:
		_vbox = VBoxContainer.new()
		_vbox.add_theme_constant_override("separation", 2)
		add_child(_vbox)


## Add a clickable item.
func add_item(label: String, callback: Callable = Callable()) -> UIFlowContextMenu:
	if not is_instance_valid(self):
		return null
	_ensure_vbox()
	var btn := Button.new()
	btn.text = label
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 30)
	btn.add_theme_font_size_override("font_size", 14)

	btn.pressed.connect(func():
		if callback.is_valid():
			callback.call()
		item_selected.emit(label)
		close()
	)

	btn.mouse_entered.connect(func():
		_hide_submenu()
	)

	_vbox.add_child(btn)
	_items.append({"type": "item", "label": label, "button": btn})
	return self


## Add a separator line.
func add_separator() -> UIFlowContextMenu:
	if not is_instance_valid(self):
		return null
	_ensure_vbox()
	var sep := HSeparator.new()
	_vbox.add_child(sep)
	_items.append({"type": "separator"})
	return self


## Add a submenu item. Returns the submenu for chaining.
func add_submenu(label: String) -> UIFlowContextMenu:
	if not is_instance_valid(self):
		return null
	_ensure_vbox()
	var btn := Button.new()
	btn.text = label + "  ▸"
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 30)
	btn.add_theme_font_size_override("font_size", 14)
	_vbox.add_child(btn)

	var sub := UIFlowContextMenu.new()
	sub.name = "Submenu_" + label
	sub.visible = false
	add_child(sub)

	btn.mouse_entered.connect(func():
		_show_submenu(sub, btn)
	)

	_items.append({"type": "submenu", "label": label, "button": btn, "submenu": sub})
	return sub


## Show the menu at a screen position.
func show_at(position: Vector2) -> void:
	# Add to viewport first; get_viewport() only works once we are in the tree.
	if not is_inside_tree():
		var tree := Engine.get_main_loop() as SceneTree
		if tree != null:
			tree.root.add_child(self)

	var viewport := get_viewport()
	if viewport == null:
		return

	global_position = position
	_clamp_to_screen()
	visible = true
	_is_open = true

	# Close on click outside
	viewport.gui_focus_changed.connect(_on_focus_changed)


## Close the menu.
func close() -> void:
	visible = false
	_is_open = false
	_hide_submenu()

	var viewport := get_viewport()
	if viewport != null and viewport.gui_focus_changed.is_connected(_on_focus_changed):
		viewport.gui_focus_changed.disconnect(_on_focus_changed)

	closed.emit()
	queue_free()


func _show_submenu(sub: UIFlowContextMenu, anchor: Control) -> void:
	_hide_submenu()
	if sub.is_inside_tree() and sub.get_parent() != get_viewport():
		sub.get_parent().remove_child(sub)
	if not sub.is_inside_tree():
		get_viewport().add_child(sub)

	var anchor_pos: Vector2 = anchor.global_position
	sub.global_position = Vector2(anchor_pos.x + anchor.size.x, anchor_pos.y)
	sub._clamp_to_screen()
	sub.visible = true
	_submenu = sub


func _hide_submenu() -> void:
	if _submenu and is_instance_valid(_submenu):
		_submenu.close()
		_submenu = null


func _clamp_to_screen() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var menu_size: Vector2 = size
	if global_position.x + menu_size.x > vp_size.x:
		global_position.x = vp_size.x - menu_size.x - 8
	if global_position.y + menu_size.y > vp_size.y:
		global_position.y = vp_size.y - menu_size.y - 8
	if global_position.x < 0:
		global_position.x = 8
	if global_position.y < 0:
		global_position.y = 8


func _on_focus_changed(control: Control) -> void:
	if _is_open and control != self and not is_ancestor_of(control):
		close()


func _unhandled_input(event: InputEvent) -> void:
	if _is_open and event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			close()
