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

var _scroll_container: ScrollContainer
var _grid: GridContainer

var _selected_index: int = -1
@export var keyboard_nav_enabled: bool = true


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	_setup_layout()


## Tell UIFlowFocusNavigator to leave arrow keys to this widget while focused.
func _uiflow_consumes_directional() -> bool:
	return keyboard_nav_enabled and has_focus() and not _data.is_empty()


func _gui_input(event: InputEvent) -> void:
	if not keyboard_nav_enabled or _data.is_empty():
		return
	if event.is_action_pressed(&"ui_down"):
		_move_selection(1)
		accept_event()
	elif event.is_action_pressed(&"ui_up"):
		_move_selection(-1)
		accept_event()
	elif event.is_action_pressed(&"ui_accept"):
		if _selected_index >= 0:
			row_clicked.emit(_selected_index, _data[_selected_index])
		accept_event()


func _move_selection(delta: int) -> void:
	if _data.is_empty():
		return
	var next := _selected_index
	if next < 0:
		next = 0 if delta > 0 else _data.size() - 1
	else:
		next = clampi(next + delta, 0, _data.size() - 1)
	_select_row(next)


func _setup_layout() -> void:
	# Let the grid expand vertically inside its parent.
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	add_child(margin)

	# Scroll body
	_scroll_container = ScrollContainer.new()
	_scroll_container.name = "Body"
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_container.follow_focus = true
	_scroll_container.focus_mode = Control.FOCUS_NONE
	_scroll_container.custom_minimum_size = Vector2(0, 320)
	margin.add_child(_scroll_container)

	_grid = GridContainer.new()
	_grid.name = "Grid"
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.focus_mode = Control.FOCUS_NONE
	_scroll_container.add_child(_grid)


## Define columns. Call before set_data.
func add_column(title: String, width: float = 120.0, sortable: bool = true) -> void:
	_columns.append(Column.new(title, width, sortable))


## Define columns from an array of dictionaries.
## Each dictionary may contain: "title" (String), "width" (float), "sortable" (bool).
func set_columns(columns: Array[Dictionary]) -> void:
	_columns.clear()
	for col in columns:
		var title: String = col.get("title", "")
		var width: float = col.get("width", 120.0)
		var sortable: bool = col.get("sortable", true)
		add_column(title, width, sortable)


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
	# Clear old immediately to avoid deferred-delete leaks in tests
	for child in _grid.get_children():
		child.free()

	_grid.columns = _columns.size()

	# Header row
	for i in range(_columns.size()):
		var col: Column = _columns[i]
		var btn := Button.new()
		btn.text = col.title
		btn.custom_minimum_size = Vector2(col.width, 40)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		if col.sortable:
			btn.pressed.connect(_on_header_clicked.bind(i))
			btn.focus_mode = Control.FOCUS_CLICK
		else:
			btn.focus_mode = Control.FOCUS_NONE
		_grid.add_child(btn)

	# Data rows
	for row_idx in range(_data.size()):
		var row_data: Array = _data[row_idx]
		for col_idx in range(_columns.size()):
			var col: Column = _columns[col_idx]
			var cell := Label.new()
			cell.text = str(row_data[col_idx]) if col_idx < row_data.size() else ""
			cell.custom_minimum_size = Vector2(col.width, 36)
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell.clip_text = true
			cell.focus_mode = Control.FOCUS_NONE
			cell.mouse_filter = Control.MOUSE_FILTER_STOP
			cell.gui_input.connect(_make_cell_input_handler(row_idx))
			_grid.add_child(cell)

	# Apply current sort indicator
	if _sort_column >= 0:
		_update_sort_indicator()


func _make_cell_input_handler(row_idx: int) -> Callable:
	return func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			grab_focus()
			_select_row(row_idx)


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
	_update_selection_display()


func _update_selection_display() -> void:
	var col_count := _columns.size()
	if col_count <= 0:
		return
	for row_idx in range(_data.size()):
		var selected := row_idx == _selected_index
		for col_idx in range(col_count):
			var child_idx := col_count + row_idx * col_count + col_idx
			if child_idx >= _grid.get_child_count():
				break
			var cell := _grid.get_child(child_idx) as Control
			if cell:
				cell.modulate = Color(0.75, 0.85, 1.0) if selected else Color.WHITE


func _update_sort_indicator() -> void:
	# Update header button text with sort arrow
	for i in range(_columns.size()):
		if i >= _grid.get_child_count():
			break
		var btn: Button = _grid.get_child(i) as Button
		if btn == null:
			continue
		var col: Column = _columns[i]
		btn.text = col.title
		if i == _sort_column:
			btn.text += " ▲" if _sort_ascending else " ▼"
