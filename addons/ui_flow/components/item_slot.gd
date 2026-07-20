## UIFlow ItemSlot — a single inventory/equipment slot with drag-and-drop support.
class_name UIFlowItemSlot extends PanelContainer

## Emitted when an item is dropped into this slot.
## [param old_item] is the previous item in this slot (null if empty).
signal item_dropped(item: ItemData, from_index: int, old_item: ItemData)

## Emitted when an item is dragged from this slot.
signal item_dragged(item: ItemData, slot_index: int)

## Emitted when the user right-clicks this slot while it holds an item.
signal right_clicked(item: ItemData, slot_index: int, global_position: Vector2)

## Slot index in the inventory.
@export var slot_index: int = -1

## Slot type filter (empty = accepts all).
@export var accept_type: StringName = &""

## Is this an equipment slot?
@export var is_equip_slot: bool = false

var _item: ItemData = null
var _icon: TextureRect
var _rarity_border: ColorRect
var _letter_label: Label
var _drag_drop: UIFlowDragDrop
var _drop_target: UIFlowDropTarget
var _empty_style: StyleBoxFlat
var _filled_style: StyleBoxFlat


func _ready() -> void:
	_setup_ui()
	_setup_drag_drop()
	gui_input.connect(_on_gui_input)
	_update_display()


func _setup_ui() -> void:
	custom_minimum_size = Vector2(56, 56)

	# Styles — keep fallback colors; components will pick up a native Theme
	# automatically unless we add an override, so we only set our own styles.
	_empty_style = StyleBoxFlat.new()
	_empty_style.bg_color = Color(0.1, 0.1, 0.13, 0.6)
	_empty_style.set_corner_radius_all(4)
	_empty_style.set_content_margin_all(4)
	_empty_style.border_color = Color(0.25, 0.25, 0.3, 0.5)
	_empty_style.set_border_width_all(1)

	_filled_style = StyleBoxFlat.new()
	_filled_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	_filled_style.set_corner_radius_all(4)
	_filled_style.set_content_margin_all(4)

	add_theme_stylebox_override("panel", _empty_style)

	# Icon
	_icon = TextureRect.new()
	_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.visible = false
	add_child(_icon)

	# Rarity border
	_rarity_border = ColorRect.new()
	_rarity_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rarity_border.color = Color.TRANSPARENT
	_rarity_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rarity_border)

	# Letter label (centered) — used when no item icon is set.
	_letter_label = Label.new()
	_letter_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	_letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_letter_label.add_theme_font_size_override("font_size", 18)
	_letter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_letter_label)


func _setup_drag_drop() -> void:
	# Drop target
	_drop_target = UIFlowDropTarget.new()
	_drop_target.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_drop_target.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_drop_target.can_drop_check = func(data):
		if data is ItemData:
			if accept_type.is_empty():
				return true
			return data.equip_slot == accept_type
		return false
	add_child(_drop_target)
	_drop_target.on_drop.connect(_on_item_drop)

	# Drag source
	_drag_drop = UIFlowDragDrop.new()
	_drag_drop.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_drag_drop.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_drag_drop)
	# Must be set after add_child because UIFlowDragDrop._ready() resets
	# mouse_filter to STOP. Default to IGNORE; set_item() enables it when
	# an item is present.
	_drag_drop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Do not hide the drag control; PanelContainer skips invisible children
	# when sorting, so a hidden drag control would have zero size forever.
	# Instead we disable input via mouse_filter when the slot is empty.
	_drag_drop.visible = true
	_drag_drop.dropped.connect(_on_drag_dropped)


## Set the item displayed in this slot.
func set_item(item: ItemData) -> void:
	_item = item
	_drag_drop.data = item
	_drag_drop.drag_icon = item.icon if item else null
	# Keep the drag control visible so PanelContainer assigns it a rect;
	# toggle input via mouse_filter instead.
	_drag_drop.mouse_filter = Control.MOUSE_FILTER_PASS if item != null else Control.MOUSE_FILTER_IGNORE
	_update_display()


## Get the current item.
func get_item() -> ItemData:
	return _item


func _update_display() -> void:
	if _item:
		_icon.texture = _item.icon
		_icon.visible = _item.icon != null
		_icon.modulate = Color.WHITE
		var rarity_color: Color = ItemData.get_rarity_color(_item.rarity)
		_rarity_border.color = rarity_color
		_rarity_border.color.a = 0.3
		_filled_style.border_color = rarity_color
		_filled_style.set_border_width_all(2)
		add_theme_stylebox_override("panel", _filled_style)
		if _item.icon == null:
			# Show first letter as fallback when no icon
			_letter_label.text = _item.item_name.left(1)
			_letter_label.add_theme_color_override("font_color", rarity_color)
		else:
			_letter_label.text = ""
			_letter_label.remove_theme_color_override("font_color")
	else:
		_icon.texture = null
		_icon.visible = false
		_rarity_border.color = Color.TRANSPARENT
		_letter_label.text = ""
		add_theme_stylebox_override("panel", _empty_style)


func _on_item_drop(data: Variant) -> void:
	if data is ItemData:
		var old_item := _item
		set_item(data)
		var from := UIFlowDragDrop.drag_source_index
		UIFlowDragDrop.drag_source_index = -1
		item_dropped.emit(data, from, old_item)


func _on_drag_dropped(target) -> void:
	print("UIFlowItemSlot._on_drag_dropped: target=", target, " slot_index=", slot_index)
	# If dropped on self, don't clear _item (inventory_grid will handle via items_changed)
	if target == _drop_target:
		UIFlowDragDrop.drag_source_index = slot_index
		item_dragged.emit(_item, slot_index)
		return
	var dragged_item := _item
	# Only clear the visual state, do NOT clear _drag_drop.data (drag system still needs it)
	_item = null
	_drag_drop.drag_icon = null
	# Keep visible so PanelContainer keeps assigning a rect; disable input instead.
	_drag_drop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_display()
	UIFlowDragDrop.drag_source_index = slot_index
	item_dragged.emit(dragged_item, slot_index)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("UIFlowItemSlot._on_gui_input: button=", event.button_index, " slot_index=", slot_index, " item=", _item)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _item != null:
			print("UIFlowItemSlot: right_clicked emit slot_index=", slot_index)
			right_clicked.emit(_item, slot_index, event.global_position)
