## Tests for UIFlowToast — notification system.
extends GdUnitTestSuite

var _toast: UIFlowToast


func before_test() -> void:
	_toast = UIFlowToast.new()
	add_child(_toast)
	await get_tree().process_frame


func after_test() -> void:
	_toast.queue_free()
	_toast = null


## Test: show_toast creates a toast item
func test_show_toast() -> void:
	_toast.show_toast("Test message", "info", 1.0)
	assert_bool(_toast.get_child_count() > 0).is_true()


## Test: show_toast info type
func test_show_toast_info() -> void:
	_toast.show_toast("Info", "info", 1.0)
	assert_that(_toast.get_child_count()).is_equal(1)


## Test: show_toast success type
func test_show_toast_success() -> void:
	_toast.show_toast("Success", "success", 1.0)
	assert_that(_toast.get_child_count()).is_equal(1)
