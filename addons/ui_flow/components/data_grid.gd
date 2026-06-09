## UIFlowDataGrid — sortable, scrollable table component.
##
## Usage:
## [codeblock]
## var grid = UIFlowDataGrid.new()
## grid.add_column("Name", 200)
## grid.add_column("Level", 80)
## grid.add_column("HP", 100)
## grid.set_data([
##     ["Warrior", 5, 150],
##     ["Mage", 3, 80],
##     ["Rogue", 7, 100],
## ])
## $Container.add_child(grid)
## [/codeblock]
class_name UIFlowDataGrid extends PanelContainer

## Column definition.
class Column:
	var title: String
	var width: float
	var sortable: bool
	var key: String

	func _init(p_title: String, p_width: float = 120.0, p_sortable: bool = true) -> void:
		title = p_title
		width = p_width
		sortable = p_sortable

signal row_selected(index: int, data: Array)
signal row_clicked(index: int, data: Array)
signal column_sorted(column_index: int, ascending: bool)

var _columns: Array[Column] = []
var _data: Array = []
var _sort_column: int = -1
var _sort_ascending: bool = true

var _header_container: HBoxContainer
var _scroll_container: ScrollContainer
var _rows_container: VBoxContainer

var _selected_index: int = -1


func _ready() -> void:
	_setup_layout()


func _setup_layout() -> void:
	var margin := MarginContainer.new()
	margin.SetAnchorsPreset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	margin.add_child(vbox)

	# Header
	_header_container = HBoxContainer.new()
	_header_container.name = "Header"
	_header_container.add_theme_constant_override("separation", 1)
	vbox.add_child(_header_container)

	# Scroll body
	_scroll_container = ScrollContainer.new()
	_scroll_container.name = "Body"
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_container.follow_focus = true
	vbox.add_child(_scroll_container)

	_rows_container = VBoxContainer.new()
	_rows_container.name = "Rows"
	_rows_container.add_theme_constant_override("separation", 1)
	_scroll_container.add_child(_rows_container)


## Define columns. Call before set_data.
func add_column(title: String, width: float = 120.0, sortable: bool = true) -> void:
	_columns.append(Column.new(title, width, sortable))


## Set the data array. Each element is an Array of column values.
func set_data(data: Array) -> void:
	_data = data
	_rebuild()


## Get the current data.
func get_data() -> Array:
	return _data


## Sort by column index.
func sort_by(column_index: int, ascending: bool = true) -> void:
	if column_index < 0 or column_index >= _columns.size():
		return
	_sort_column = column_index
	_sort_ascending = ascending
	_data.sort_custom(func(a, b):
		var va = a[column_index] if column_index < a.size() else null
		var vb = b[column_index] if column_index < b.size() else null
		if va == null: return true
		if vb == null: return false
		if ascending:
			return va < vb
		else:
			return va > vb
	)
	column_sorted.emit(column_index, ascending)
	_rebuild()


## Get selected row data.
func get_selected() -> Array:
	if _selected_index >= 0 and _selected_index < _data.size():
		return _data[_selected_index]
	return []


func _rebuild() -> void:
	# Clear old
	for child in _header_container.get_children():
		child.queue_free()
	for child in _rows_container.get_children():
		child.queue_free()

	# Build header
	for i in range(_columns.size()):
		var col: Column = _columns[i]
		var btn := Button.new()
		btn.text = col.title
		btn.custom_minimum_size = Vector2(col.width, 32)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true

		if col.sortable:
			btn.pressed.connect(func(): _on_header_clicked(i))

		_header_container.add_child(btn)

	# Build rows
	for row_idx in range(_data.size()):
		var row_data: Array = _data[row_idx]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 1)

		for col_idx in range(_columns.size()):
			var col: Column = _columns[col_idx]
			var cell := Label.new()
			cell.text = str(row_data[col_idx]) if col_idx < row_data.size() else ""
			cell.custom_minimum_size = Vector2(col.width, 28)
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell.clip_text = true
			row.add_child(cell)

		# Row click
		var idx := row_idx
		var click_rect := ColorRect.new()
		click_rect.color = Color.TRANSPARENT
		click_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		click_rect.custom_minimum_size = Vector2(0, 0)
		click_rect.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select_row(idx)
		)

		_rows_container.add_child(row)

	# Apply current sort indicator
	if _sort_column >= 0:
		_update_sort_indicator()


func _on_header_clicked(column_index: int) -> void:
	if _sort_column == column_index:
		_sort_ascending = not _sort_ascending
	else:
		_sort_column = column_index
		_sort_ascending = true
	sort_by(_sort_column, _sort_ascending)


func _select_row(index: int) -> void:
	_selected_index = index
	if index >= 0 and index < _data.size():
		row_selected.emit(index, _data[index])


func _update_sort_indicator() -> void:
	# Update header button text with sort arrow
	for i in range(_header_container.get_child_count()):
		var btn: Button = _header_container.get_child(i) as Button
		if btn == null:
			continue
		var col: Column = _columns[i]
		btn.text = col.title
		if i == _sort_column:
			btn.text += " ▲" if _sort_ascending else " ▼"
