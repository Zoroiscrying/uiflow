## Tests for UIFlowTransitionManager — preset loading and transition playback.
extends GdUnitTestSuite

var _manager: UIFlowTransitionManager


func before_test() -> void:
	_manager = UIFlowTransitionManager.new()


func after_test() -> void:
	_manager = null


## Test: builtin presets are loaded
func test_builtin_presets_loaded() -> void:
	var fade: UIFlowTransition = _manager.get_preset_resource(UIFlowTransitionType.Type.FADE)
	assert_that(fade).is_not_null()
	assert_that(fade.type).is_equal(UIFlowTransitionType.Type.FADE)
	assert_that(fade.duration).is_equal(0.3)


## Test: all 7 presets exist
func test_all_presets_exist() -> void:
	var types := [
		UIFlowTransitionType.Type.NONE,
		UIFlowTransitionType.Type.FADE,
		UIFlowTransitionType.Type.SLIDE_LEFT,
		UIFlowTransitionType.Type.SLIDE_RIGHT,
		UIFlowTransitionType.Type.SLIDE_UP,
		UIFlowTransitionType.Type.SLIDE_DOWN,
		UIFlowTransitionType.Type.SCALE,
	]
	for type in types:
		var preset: UIFlowTransition = _manager.get_preset_resource(type)
		assert_that(preset).is_not_null()


## Test: get_preset returns UIFlowTransitionBase instance
func test_get_preset_returns_instance() -> void:
	var instance: UIFlowTransitionBase = _manager.get_preset(UIFlowTransitionType.Type.FADE)
	assert_that(instance).is_not_null()
	assert_that(instance).is_instanceof(UIFlowTransitionFade)


## Test: default transition is FADE
func test_default_transition() -> void:
	var default_inst: UIFlowTransitionBase = _manager.default_transition()
	assert_that(default_inst).is_instanceof(UIFlowTransitionFade)


## Test: set_default changes default
func test_set_default() -> void:
	_manager.set_default(UIFlowTransitionType.Type.SCALE)
	var default_inst: UIFlowTransitionBase = _manager.default_transition()
	assert_that(default_inst).is_instanceof(UIFlowTransitionScale)


## Test: create_instance_from_resource
func test_create_instance_from_resource() -> void:
	var res := UIFlowTransition.new()
	res.type = UIFlowTransitionType.Type.SLIDE_LEFT
	res.duration = 0.5
	var instance: UIFlowTransitionBase = _manager.create_instance_from_resource(res)
	assert_that(instance).is_instanceof(UIFlowTransitionSlideLeft)


## Test: create_instance with inline params
func test_create_instance_inline() -> void:
	var instance: UIFlowTransitionBase = _manager.create_instance(
		UIFlowTransitionType.Type.FADE, 0.5, Tween.EASE_OUT, Tween.TRANS_CUBIC
	)
	assert_that(instance).is_instanceof(UIFlowTransitionFade)


## Test: register_custom and get_custom_preset
func test_custom_preset() -> void:
	var custom := UIFlowTransition.new()
	custom.type = UIFlowTransitionType.Type.FADE
	custom.duration = 1.0
	_manager.register_custom("slow_fade", custom)

	var retrieved: UIFlowTransition = _manager.get_custom_preset("slow_fade")
	assert_that(retrieved).is_same(custom)


## Test: get_custom_preset returns null for unknown name
func test_custom_preset_unknown() -> void:
	var result: UIFlowTransition = _manager.get_custom_preset("nonexistent")
	assert_that(result).is_null()
