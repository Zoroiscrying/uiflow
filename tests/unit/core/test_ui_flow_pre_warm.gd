extends GdUnitTestSuite


func test_pre_warm_caches_scene() -> void:
	var scene := await UIFlow.Scenes.resolve_async(SharedElementHubPage)
	assert_object(scene).is_not_null()
	assert_bool(UIFlow.Scenes._cache.has(SharedElementHubPage)).is_true()
