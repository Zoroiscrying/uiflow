## Tests for UIFlowTweenProp — enum to property path conversion.
extends GdUnitTestSuite


## Test: all enum values produce valid paths
func test_all_paths_valid() -> void:
	var props := [
		UIFlowTweenProp.Prop.POSITION_X,
		UIFlowTweenProp.Prop.POSITION_Y,
		UIFlowTweenProp.Prop.POSITION,
		UIFlowTweenProp.Prop.MODULATE_A,
		UIFlowTweenProp.Prop.MODULATE,
		UIFlowTweenProp.Prop.SCALE_X,
		UIFlowTweenProp.Prop.SCALE_Y,
		UIFlowTweenProp.Prop.SCALE,
		UIFlowTweenProp.Prop.ROTATION,
		UIFlowTweenProp.Prop.SIZE_X,
		UIFlowTweenProp.Prop.SIZE_Y,
		UIFlowTweenProp.Prop.SIZE,
	]
	for prop in props:
		var path: String = UIFlowTweenProp.to_path(prop)
		assert_that(path).is_not_empty()


## Test: specific path mappings
func test_position_x() -> void:
	assert_that(UIFlowTweenProp.to_path(UIFlowTweenProp.Prop.POSITION_X)).is_equal("position:x")

func test_modulate_a() -> void:
	assert_that(UIFlowTweenProp.to_path(UIFlowTweenProp.Prop.MODULATE_A)).is_equal("modulate:a")

func test_scale() -> void:
	assert_that(UIFlowTweenProp.to_path(UIFlowTweenProp.Prop.SCALE)).is_equal("scale")
