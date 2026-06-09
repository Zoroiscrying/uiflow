## ItemSlot — a single inventory/equipment slot with drag-and-drop support.
class_name UIFlowItemSlot extends PanelContainer

## Emitted when an item is dropped into this slot.
signal item_dropped(item: ItemData, from_index: int)

## Emitted when an item is dragged from this slot.
signal item_dragged(item: ItemData, slot_index: int)

## Slot index in the inventory.
@export var slot_index: int = -1

## Slot type filter (empty = accepts all).
@export var accept_type: StringName = &""

## Is this an equipment slot?
@export var is_equip_slot: bool = false

var _item: ItemData = null
var _icon: TextureRect
var _rarity_border: ColorRect
var _count_label: Label
var _drag_drop: UIFlowDragDrop
var _drop_target: UIFlowDropTarget
var _empty_style: StyleBoxFlat
var _filled_style: StyleBoxFlat


func _ready() -> void:
	_setup_ui()
	_setup_drag_drop()
	_update_display()


func _setup_ui() -> void:
	custom_minimum_size = Vector2(56, 56)

	# Styles
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
	add_child(_icon)

	# Rarity border
	_rarity_border = ColorRect.new()
	_rarity_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rarity_border.color = Color.TRANSPARENT
	_rarity_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rarity_border)

	# Count label (bottom-right)
	_count_label = Label.new()
	_count_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_count_label.add_theme_font_size_override("font_size", 12)
	_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_count_label)


func _setup_drag_drop() -> void:
	# Drop target
	_drop_target = UIFlowDropTarget.new()
	_drop_target.can_drop_check = func(data):
		if data is ItemData:
			if accept_type.is_empty():
				return true
			return data.type == accept_type or data.equip_slot == accept_type
		return false
	add_child(_drop_target)
	_drop_target.on_drop.connect(_on_item_drop)

	# Drag source
	_drag_drop = UIFlowDragDrop.new()
	_drag_drop.visible = false  # Only active when item exists
	add_child(_drag_drop)
	_drag_drop.dropped.connect(_on_drag_dropped)


## Set the item displayed in this slot.
func set_item(item: ItemData) -> void:
	_item = item
	_drag_drop.data = item
	_drag_drop.drag_icon = item.icon if item else null
	_drag_drop.visible = item != null
	_update_display()


## Get the current item.
func get_item() -> ItemData:
	return _item


func _update_display() -> void:
	if _item:
		_icon.texture = _item.icon
		_icon.modulate = Color.WHITE
		_rarity_border.color = ItemData.get_rarity_color(_item.rarity)
		_rarity_border.color.a = 0.3
		_filled_style.border_color = ItemData.get_rarity_color(_item.rarity)
		_filled_style.set_border_width_all(2)
		add_theme_stylebox_override("panel", _filled_style)
		_count_label.text = ""
	else:
		_icon.texture = null
		_rarity_border.color = Color.TRANSPARENT
		_count_label.text = ""
		add_theme_stylebox_override("panel", _empty_style)


func _on_item_drop(data: Variant) -> void:
	if data is ItemData:
		var old_item := _item
		set_item(data)
		if old_item:
			# Return old item to source
			pass
		item_dropped.emit(data, -1)


func _on_drag_dropped(target) -> void:
	set_item(null)
	item_dragged.emit(_item, slot_index)
