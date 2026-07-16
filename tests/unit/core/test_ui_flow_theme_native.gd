## Tests for native Godot Theme support in UIFlow.
extends GdUnitTestSuite


## Test: ThemeHelper applies and returns a native Godot Theme.
func test_theme_helper_applies_godot_theme() -> void:
	var helper := UIFlowThemeHelper.new()
	var native := Theme.new()
	native.set_color("font_color", "Label", Color.RED)

	helper.apply_godot_theme(native)

	assert_that(helper.get_godot_theme()).is_same(native)
	assert_that(helper.get_godot_theme().get_color("font_color", "Label")).is_equal(Color.RED)


## Test: ThemeHelper falls back to the built-in dark Godot theme.
func test_theme_helper_default_godot_theme_exists() -> void:
	var helper := UIFlowThemeHelper.new()
	var godot_theme: Theme = helper.get_godot_theme()
	assert_that(godot_theme).is_not_null()
	assert_that(godot_theme is Theme).is_true()


## Test: UIFlowThemeHelper still supports legacy UIFlowTheme.
func test_theme_helper_legacy_uiflow_theme_still_works() -> void:
	var helper := UIFlowThemeHelper.new()
	var legacy := UIFlowTheme.new()
	legacy.primary = Color.GREEN

	helper.apply_theme(legacy)

	assert_that(helper.get_current()).is_same(legacy)
	assert_that(helper.get_color(UIFlowTheme.ColorSlot.PRIMARY)).is_equal(Color.GREEN)


## Test: Navigator push accepts a native Theme and applies it to the page.
func test_navigator_push_with_native_theme() -> void:
	var container := Control.new()
	add_child(container)
	var resolver := UIFlowSceneResolver.new()
	var navigator := UIFlowNavigator.new()
	add_child(navigator)
	navigator.setup(container, resolver)

	var page_script := GDScript.new()
	page_script.source_code = "class_name TestNativeThemePage extends UIFlowPage"
	page_script.reload()

	var scene := PackedScene.new()
	var page_node := UIFlowPage.new()
	page_node.set_script(page_script)
	scene.pack(page_node)
	page_node.queue_free()

	resolver.register_scene(page_script, scene)

	var native := Theme.new()
	native.set_color("font_color", "Label", Color.BLUE)
	var instance: Control = navigator.push(page_script, null, native)

	assert_that(instance).is_not_null()
	assert_that(instance.theme).is_same(native)
	assert_that(instance.theme.get_color("font_color", "Label")).is_equal(Color.BLUE)

	navigator.pop()
	navigator.queue_free()
	container.queue_free()


## Test: Navigator push still accepts a legacy UIFlowTheme.
func test_navigator_push_with_legacy_uiflow_theme() -> void:
	var container := Control.new()
	add_child(container)
	var resolver := UIFlowSceneResolver.new()
	var navigator := UIFlowNavigator.new()
	add_child(navigator)
	navigator.setup(container, resolver)

	var page_script := GDScript.new()
	page_script.source_code = "class_name TestLegacyThemePage extends UIFlowPage"
	page_script.reload()

	var scene := PackedScene.new()
	var page_node := UIFlowPage.new()
	page_node.set_script(page_script)
	scene.pack(page_node)
	page_node.queue_free()

	resolver.register_scene(page_script, scene)

	var legacy := UIFlowTheme.new()
	legacy.primary = Color.YELLOW
	var instance: Control = navigator.push(page_script, null, legacy)

	assert_that(instance).is_not_null()
	assert_that(instance.theme).is_not_null()
	var built_in: Theme = instance.theme
	assert_that(built_in.get_color("font_color", "Label")).is_equal(legacy.resolved_on_surface())

	navigator.pop()
	navigator.queue_free()
	container.queue_free()
