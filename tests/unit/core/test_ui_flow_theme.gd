## Tests for UIFlowTheme — hierarchical theme with parent-child inheritance.
extends GdUnitTestSuite


## Test: default values without parent
func test_default_values() -> void:
	var theme := UIFlowTheme.new()
	assert_that(theme.resolved_primary()).is_equal(Color(0.31, 0.55, 1.0))
	assert_that(theme.resolved_surface()).is_equal(Color(0.11, 0.11, 0.14))
	assert_that(theme.resolved_font_size_body()).is_equal(14)
	assert_that(theme.resolved_spacing_sm()).is_equal(8)


## Test: set_color marks override
func test_set_color_marks_override() -> void:
	var theme := UIFlowTheme.new()
	theme.primary = Color.RED
	assert_that(theme.has_override("primary")).is_true()
	assert_that(theme.resolved_primary()).is_equal(Color.RED)


## Test: unset properties inherit from parent
func test_parent_inheritance() -> void:
	var parent := UIFlowTheme.new()
	parent.primary = Color.BLUE
	parent.surface = Color.BLACK

	var child := UIFlowTheme.new()
	child.parent_theme = parent
	child.accent = Color.GOLD

	# child inherits primary from parent
	assert_that(child.resolved_primary()).is_equal(Color.BLUE)
	# child has its own accent
	assert_that(child.resolved_accent()).is_equal(Color.GOLD)
	# child inherits surface from parent
	assert_that(child.resolved_surface()).is_equal(Color.BLACK)


## Test: child override takes priority over parent
func test_child_override_priority() -> void:
	var parent := UIFlowTheme.new()
	parent.primary = Color.BLUE

	var child := UIFlowTheme.new()
	child.parent_theme = parent
	child.primary = Color.RED

	assert_that(child.resolved_primary()).is_equal(Color.RED)


## Test: 3-level inheritance chain
func test_three_level_chain() -> void:
	var grandparent := UIFlowTheme.new()
	grandparent.primary = Color.WHITE
	grandparent.surface = Color.BLACK

	var parent := UIFlowTheme.new()
	parent.parent_theme = grandparent
	parent.surface = Color.GRAY

	var child := UIFlowTheme.new()
	child.parent_theme = parent

	# child inherits primary from grandparent (through parent)
	assert_that(child.resolved_primary()).is_equal(Color.WHITE)
	# child inherits surface from parent (which overrode grandparent)
	assert_that(child.resolved_surface()).is_equal(Color.GRAY)


## Test: has_override returns false for inherited properties
func test_has_override_false_for_inherited() -> void:
	var parent := UIFlowTheme.new()
	parent.primary = Color.BLUE

	var child := UIFlowTheme.new()
	child.parent_theme = parent

	assert_that(child.has_override("primary")).is_false()
	assert_that(child.resolved_primary()).is_equal(Color.BLUE)


## Test: get_color with slot enum
func test_get_color_slot() -> void:
	var theme := UIFlowTheme.new()
	theme.error = Color.RED
	var color: Color = theme.get_color(UIFlowTheme.ColorSlot.ERROR)
	assert_that(color).is_equal(Color.RED)


## Test: build_godot_theme produces valid Theme
func test_build_godot_theme() -> void:
	var theme := UIFlowTheme.new()
	var godot_theme: Theme = theme.build_godot_theme()
	assert_that(godot_theme).is_not_null()
	# Verify Button has stylebox
	var btn_style: StyleBox = godot_theme.get_stylebox("normal", "Button")
	assert_that(btn_style).is_not_null()
	# Verify Label has font color
	var label_color: Color = godot_theme.get_color("font_color", "Label")
	assert_that(label_color).is_equal(theme.resolved_on_surface())


## Test: build_godot_theme uses resolved values (parent chain)
func test_build_godot_theme_uses_parent() -> void:
	var parent := UIFlowTheme.new()
	parent.primary = Color.RED

	var child := UIFlowTheme.new()
	child.parent_theme = parent

	var godot_theme: Theme = child.build_godot_theme()
	# ProgressBar fill should use parent's primary (RED)
	var fill: StyleBoxFlat = godot_theme.get_stylebox("fill", "ProgressBar") as StyleBoxFlat
	assert_that(fill).is_not_null()
	assert_that(fill.bg_color).is_equal(Color.RED)


## Test: get_property/set_property for arbitrary keys
func test_get_set_property() -> void:
	var theme := UIFlowTheme.new()
	theme.set_property("custom_shadow", Color.BLACK)
	assert_that(theme.get_property("custom_shadow")).is_equal(Color.BLACK)
	assert_that(theme.has_override("custom_shadow")).is_true()


## Test: remove_override reverts to parent
func test_remove_override() -> void:
	var parent := UIFlowTheme.new()
	parent.primary = Color.BLUE

	var child := UIFlowTheme.new()
	child.parent_theme = parent
	child.primary = Color.RED
	assert_that(child.resolved_primary()).is_equal(Color.RED)

	child.remove_override("primary")
	assert_that(child.has_override("primary")).is_false()
	assert_that(child.resolved_primary()).is_equal(Color.BLUE)


## Test: get_local_keys returns only overridden keys
func test_get_local_keys() -> void:
	var theme := UIFlowTheme.new()
	theme.set_property("shadow", Color.BLACK)
	theme.set_property("glow", Color.YELLOW)
	var keys = theme.get_local_keys()
	assert_that(keys).has_size(2)
	assert_that(keys).contains("shadow")
	assert_that(keys).contains("glow")


## Test: theme_name property
func test_theme_name() -> void:
	var theme := UIFlowTheme.new()
	theme.theme_name = "dark_pro"
	assert_that(theme.theme_name).is_equal("dark_pro")
	assert_that(theme.has_override("theme_name")).is_true()
