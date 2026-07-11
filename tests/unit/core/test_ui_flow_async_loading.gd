extends GdUnitTestSuite


const AsyncTestPage := preload("res://tests/unit/core/async_test_page.gd")


func test_push_async_returns_instance() -> void:
	var page := AsyncTestPage.new()
	var scene := PackedScene.new()
	scene.pack(page)
	page.queue_free()
	UIFlow.register_scene(AsyncTestPage, scene)

	var instance := await UIFlow.push_async(AsyncTestPage) as Control
	assert_object(instance).is_not_null()
	await get_tree().create_timer(0.1).timeout
	UIFlow.pop()
	await UIFlow.page_closed
