## Tests for load-progress forwarding in push_async_with_loading.
extends GdUnitTestSuite

const AsyncProgressPage := preload("res://tests/unit/core/async_progress_page.gd")
const AsyncProgressLoadingPage := preload("res://tests/unit/core/async_progress_loading_page.gd")


func before_test() -> void:
	AsyncProgressLoadingPage.progress_log.clear()
	# Force a real threaded disk load instead of a cache hit.
	UIFlow.Scenes._cache.erase(AsyncProgressPage)
	UIFlow.Scenes.add_scene_dir("res://tests/unit/core/")


func after_test() -> void:
	# Pop is synchronous when the page has no exit effect (page_closed fires
	# inside pop()), async otherwise — wait only when the stack did not shrink.
	while UIFlow.stack_depth() > 0:
		var depth := UIFlow.stack_depth()
		UIFlow.pop()
		while UIFlow.stack_depth() == depth:
			await UIFlow.page_closed


## Loading pages implementing set_progress receive progress ending at 1.0.
func test_progress_forwarded_to_loading_page() -> void:
	var loading_page := AsyncProgressLoadingPage.new()
	var loading_scene := PackedScene.new()
	loading_scene.pack(loading_page)
	loading_page.queue_free()
	UIFlow.register_scene(AsyncProgressLoadingPage, loading_scene)

	var instance := await UIFlow.push_async_with_loading(
		AsyncProgressPage, {}, null, AsyncProgressLoadingPage) as Control
	assert_object(instance).is_not_null()

	var log: Array = AsyncProgressLoadingPage.progress_log
	assert_that(log).is_not_empty()
	assert_that(log[-1]).is_equal(1.0)
	for p in log:
		assert_that(p).is_between(0.0, 1.0)

	# Loading page removed; target sits on top of the stack.
	assert_that(UIFlow.is_on_top(AsyncProgressPage)).is_true()
	assert_that(UIFlow.has_page(AsyncProgressLoadingPage)).is_false()


## A loading page without set_progress still works (progress is skipped).
func test_loading_page_without_progress_method() -> void:
	var loading_page := UIFlowPage.new()
	var loading_scene := PackedScene.new()
	loading_scene.pack(loading_page)
	loading_page.queue_free()
	UIFlow.register_scene(AsyncProgressLoadingPage, loading_scene)

	var instance := await UIFlow.push_async_with_loading(
		AsyncProgressPage, {}, null, AsyncProgressLoadingPage) as Control
	assert_object(instance).is_not_null()
	assert_that(UIFlow.is_on_top(AsyncProgressPage)).is_true()
