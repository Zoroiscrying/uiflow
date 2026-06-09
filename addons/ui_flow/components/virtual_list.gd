## UIFlowVirtualList — renders only visible items for performance.
##
## Supports thousands of items with constant rendering cost.
## Only creates UI instances for items currently in the viewport.
##
## Usage:
## [codeblock]
## var vlist = UIFlowVirtualList.new()
## vlist.item_scene = preload("res://item_slot.tscn")
## vlist.item_height = 48
## vlist.total_count = 10000
## vlist.on_update.connect(func(node, index):
##     node.get_node("Label").text = "Item %d" % index
## )
## $Container.add_child(vlist)
## [/codeblock]
class_name UIFlowVirtualList extends ScrollContainer

## Scene used for each visible item.
@export var item_scene: PackedScene

## Height of each item in pixels.
@export var item_height: float = 48.0

## Gap between items.
@export var item_gap: float = 2.0

## Total number of items in the data set.
@export var total_count: int = 0:
	set(v):
		total_count = v
		_update_scroll_area()

## Emitted when an item node needs to be updated.
## Callback: (node: Control, index: int)
signal on_update(node: Control, index: int)

var _content: VBoxContainer
var _spacer_top: Control
var _spacer_bottom: Control
var _visible_items: Dictionary = {} # index -> Control
var _pool: Array[Control] = []
var _last_scroll: float = 0.0


func _ready() -> void:
	_setup_layout()
	scroll_vertical_changed.connect(_on_scroll_changed)


func _setup_layout() -> void:
	_content = VBoxContainer.new()
	_content.name = "VirtualContent"
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_content)

	_spacer_top = Control.new()
	_spacer_top.name = "SpacerTop"
	_spacer_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_spacer_top)

	_spacer_bottom = Control.new()
	_spacer_bottom.name = "SpacerBottom"
	_spacer_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_spacer_bottom)


func _update_scroll_area() -> void:
	if _content == null:
		return
	var total_height: float = total_count * (item_height + item_gap)
	var visible_height: float = size.y
	_spacer_bottom.custom_minimum_size.y = maxf(0, total_height - visible_height)
	_refresh_visible()


func _on_scroll_changed() -> void:
	_refresh_visible()


func _process(_delta: float) -> void:
	if scroll_vertical != _last_scroll:
		_last_scroll = scroll_vertical
		_refresh_visible()


func _refresh_visible() -> void:
	if item_scene == null or total_count == 0:
		return

	var scroll_pos: float = scroll_vertical
	var view_height: float = size.y
	var first_visible: int = maxi(0, int(scroll_pos / (item_height + item_gap)))
	var last_visible: int = mini(total_count - 1, int((scroll_pos + view_height) / (item_height + item_gap)) + 1)

	# Remove items that are no longer visible
	var to_remove: Array = []
	for idx in _visible_items:
		if idx < first_visible or idx > last_visible:
			to_remove.append(idx)
	for idx in to_remove:
		_recycle_item(idx)

	# Add items that are now visible
	for idx in range(first_visible, last_visible + 1):
		if not _visible_items.has(idx):
			_create_item(idx)

	# Update spacer positions
	_spacer_top.custom_minimum_size.y = first_visible * (item_height + item_gap)


func _create_item(index: int) -> Control:
	var item: Control
	if _pool.size() > 0:
		item = _pool.pop_back()
		item.visible = true
	else:
		item = item_scene.instantiate()
		_content.add_child(item)
		_content.move_child(item, _content.get_child_count() - 2) # Before spacer_bottom

	item.position.y = index * (item_height + item_gap)
	_visible_items[index] = item
	on_update.emit(item, index)
	return item


func _recycle_item(index: int) -> void:
	if _visible_items.has(index):
		var item: Control = _visible_items[index]
		item.visible = false
		_pool.append(item)
		_visible_items.erase(index)


## Force refresh all visible items.
func refresh() -> void:
	for idx in _visible_items:
		on_update.emit(_visible_items[idx], idx)


## Set total count and reset scroll.
func set_total_count(count: int) -> void:
	total_count = count
	scroll_vertical = 0
