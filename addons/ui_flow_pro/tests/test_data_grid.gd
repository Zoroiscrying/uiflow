## Tests for UIFlowDataGrid — sortable, scrollable table.
extends GdUnitTestSuite

var _grid: UIFlowDataGrid


func before_test() -> void:
	_grid = UIFlowDataGrid.new()
	add_child(_grid)
	await get_tree().process_frame


func after_test() -> void:
	_grid.queue_free()
	_grid = null


## Test: add_column stores columns
func test_add_column() -> void:
	_grid.add_column("Name", 100, false)
	_grid.add_column("Value", 80, true)
	assert_that(_grid._columns).has_size(2)


## Test: set_data populates and get_data returns it
func test_set_data() -> void:
	_grid.add_column("Name", 100, false)
	_grid.add_column("Value", 80, false)
	var data := [["HP", "100"], ["MP", "50"]]
	_grid.set_data(data)
	assert_that(_grid.get_data()).has_size(2)
	assert_that(_grid.get_data()[0]).is_equal(["HP", "100"])


## Test: set_data with empty array clears
func test_set_data_empty() -> void:
	_grid.add_column("Name", 100, false)
	_grid.set_data([["A"]])
	_grid.set_data([])
	assert_that(_grid.get_data()).has_size(0)


## Test: sort_by reorders data
func test_sort_by() -> void:
	_grid.add_column("Name", 100, true)
	_grid.add_column("Level", 80, true)
	_grid.set_data([["Rogue", "7"], ["Warrior", "5"], ["Mage", "3"]])
	_grid.sort_by(1, true)
	var sorted := _grid.get_data()
	assert_that(sorted[0][1]).is_equal("3")
	assert_that(sorted[2][1]).is_equal("7")


## Test: get_selected returns empty when nothing selected
func test_get_selected_empty() -> void:
	_grid.add_column("Name", 100, false)
	_grid.set_data([["A"]])
	assert_that(_grid.get_selected()).is_empty()


## Test: column_sorted signal fires
func test_column_sorted_signal() -> void:
	var received: Array = []
	_grid.column_sorted.connect(func(idx, asc): received.append([idx, asc]))
	_grid.add_column("Name", 100, true)
	_grid.set_data([["B"], ["A"]])
	_grid.sort_by(0, true)
	assert_that(received[0][0]).is_equal(0)
	assert_that(received[0][1]).is_true()
