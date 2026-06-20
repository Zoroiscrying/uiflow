## UIFlow — The main autoload singleton providing the unified API.
extends Node

# ── Sub-systems ──────────────────────────────────────────────────────────────

## Navigation operations (push/pop/replace).
var Router: UIFlowNavigator
## Scene resolution (class_name → PackedScene).
var Scenes: UIFlowSceneResolver
## Input handling and focus management.
var FlowInput: UIFlowInputHandler
## Theme utilities and named color palette.
var ThemeHelper: UIFlowThemeHelper
## Global configuration.
var Config: UIFlowConfig

# ── Internal ─────────────────────────────────────────────────────────────────

var _page_container: Control
var _custom_ui_root: Control = null

const _CONFIG_PATH := "res://ui_flow_config.tres"


# ── Signals (forwarded from Router) ─────────────────────────────────────────

## Emitted when a page's _on_opened completes (awaitable).
signal page_opened(page_class: GDScript)
## Emitted when a page's _on_closed completes (awaitable).
signal page_closed(page_class: GDScript)


func _ready() -> void:
	_load_config()

	Scenes = UIFlowSceneResolver.new()
	ThemeHelper = UIFlowThemeHelper.new()

	# Apply config to scene resolver
	if Config and not Config.scene_directory.is_empty():
		Scenes.add_scene_dir(Config.scene_directory)

	# Apply default theme from config
	if Config and not Config.default_theme_name.is_empty():
		ThemeHelper.apply_builtin(Config.default_theme_name)

	Router = UIFlowNavigator.new()
	Router.name = "UIFlowNavigator"
	add_child(Router)
	Router.page_opened.connect(func(c): page_opened.emit(c))
	Router.page_closed.connect(func(c): page_closed.emit(c))

	FlowInput = UIFlowInputHandler.new()
	FlowInput.name = "UIFlowInputHandler"
	add_child(FlowInput)
	FlowInput.setup(Router)
	FlowInput.back_pressed.connect(_on_back_pressed)


func _load_config() -> void:
	if ResourceLoader.exists(_CONFIG_PATH):
		Config = load(_CONFIG_PATH) as UIFlowConfig
	if Config == null:
		Config = UIFlowConfig.new()

	# Override from ProjectSettings if present
	if ProjectSettings.has_setting("ui_flow/scene_directory"):
		var dir: String = ProjectSettings.get_setting("ui_flow/scene_directory")
		if not dir.is_empty():
			Config.scene_directory = dir
	if ProjectSettings.has_setting("ui_flow/max_stack_depth"):
		Config.max_stack_depth = ProjectSettings.get_setting("ui_flow/max_stack_depth") as int
	if ProjectSettings.has_setting("ui_flow/modal_close_on_back"):
		Config.modal_close_on_back = ProjectSettings.get_setting("ui_flow/modal_close_on_back") as bool
	if ProjectSettings.has_setting("ui_flow/default_theme_name"):
		Config.default_theme_name = ProjectSettings.get_setting("ui_flow/default_theme_name") as String


func _on_back_pressed() -> void:
	pass


## Set a custom Control node as the UI root for pages.
func set_ui_root(root: Control) -> void:
	_custom_ui_root = root
	_page_container = root
	Router.setup(_page_container, Scenes)
	_apply_theme_to_container()


func _ensure_page_container() -> void:
	if _page_container:
		return

	if _custom_ui_root:
		_page_container = _custom_ui_root
	else:
		var ui_layer := CanvasLayer.new()
		ui_layer.name = "UIFlowPageLayer"
		ui_layer.layer = 10
		add_child(ui_layer)

		_page_container = Control.new()
		_page_container.name = "UIFlowPageContainer"
		_page_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		_page_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_page_container.grow_vertical = Control.GROW_DIRECTION_BOTH
		ui_layer.add_child(_page_container)

	Router.setup(_page_container, Scenes)
	_apply_theme_to_container()


# ── Router shortcuts ─────────────────────────────────────────────────────────

## Push a page. Returns the page instance.
func push(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null) -> Control:
	_ensure_page_container()
	return Router.push(page_class, data, page_theme)


## Push a pre-instantiated page.
func push_instance(instance: Control, data: Variant = null) -> Control:
	_ensure_page_container()
	return Router.push_instance(instance, data)


## Pop the top page.
func pop() -> void:
	Router.pop()


## Replace the top page.
func replace(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null) -> Control:
	_ensure_page_container()
	return Router.replace(page_class, data, page_theme)


## Remove all pages except root.
func pop_to_root() -> void:
	Router.pop_to_root()


## Close a specific page by class, anywhere in the stack.
func close(page_class: GDScript) -> void:
	Router.close(page_class)


## Get the class of the current top page.
func current_page() -> GDScript:
	return Router.current_page_class()


## Get stack depth.
func stack_depth() -> int:
	return Router.depth()


## Get navigation path.
func navigation_path() -> Array[StringName]:
	return Router.navigation_path()


## Find a page in the stack by class.
func get_page(page_class: GDScript) -> Control:
	return Router.get_page(page_class)


## Check if a page is in the stack.
func has_page(page_class: GDScript) -> bool:
	return Router.has_page(page_class)


## Check if a page is the top page in the stack.
func is_on_top(page_class: GDScript) -> bool:
	return Router.is_on_top(page_class)


# ── Guard shortcuts ──────────────────────────────────────────────────────────

## Add a global navigation guard.
## Guard receives (from_page, to_page, data) and returns true to allow, false to block.
##
## Example:
## [codeblock]
## UIFlow.add_guard(func(from, to, data):
##     if Game.in_combat():
##         UIFlowUI.Toast.show_toast("Can't open menu in combat!", "warning")
##         return false
##     return true
## )
## [/codeblock]
func add_guard(guard: Callable) -> void:
	Router.get_guard().add_guard(guard)


## Remove a global guard.
func remove_guard(guard: Callable) -> void:
	Router.get_guard().remove_guard(guard)


## Add a guard for a specific target page.
func add_page_guard(page_class: GDScript, guard: Callable) -> void:
	Router.get_guard().add_page_guard(page_class, guard)


## Remove a page-specific guard.
func remove_page_guard(page_class: GDScript, guard: Callable) -> void:
	Router.get_guard().remove_page_guard(page_class, guard)


## Clear all guards.
func clear_guards() -> void:
	Router.get_guard().clear()


# ── Scene registration ───────────────────────────────────────────────────────

## Register a custom scene mapping.
func register_scene(page_class: GDScript, scene: PackedScene) -> void:
	Scenes.register_scene(page_class, scene)


# ── Animation utilities (for pages to use in their own callbacks) ────────────

## Animate a property using TweenProp enum.
func animate(
	node: Node,
	prop: UIFlowTweenProp.Prop,
	from: Variant,
	to: Variant,
	duration: float = 0.3,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
) -> Tween:
	return UIFlowAnimator.animate(node, prop, from, to, duration, ease_type, trans_type)


## Animate using raw property path.
func animate_raw(
	node: Node,
	prop_path: String,
	from: Variant,
	to: Variant,
	duration: float = 0.3,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
) -> Tween:
	return UIFlowAnimator.animate_raw(node, prop_path, from, to, duration, ease_type, trans_type)


## Create a sequencer.
func sequencer() -> UIFlowSequencer:
	return UIFlowAnimator.sequencer()


# ── Animation presets ────────────────────────────────────────────────────────

const _AnimPresets = preload("res://addons/ui_flow/core/ui_flow_anim_presets.gd")

func anim_hover_enter(node: Control) -> Tween:
	return _AnimPresets.hover_scale(node)

func anim_hover_exit(node: Control) -> Tween:
	return _AnimPresets.hover_reset(node)

func anim_press_down(node: Control) -> Tween:
	return _AnimPresets.press_down(node)

func anim_press_up(node: Control) -> Tween:
	return _AnimPresets.press_up(node)

func anim_shake(node: Control, intensity: float = 8.0) -> Tween:
	return _AnimPresets.shake(node, intensity)

func anim_pulse(node: Control) -> Tween:
	return _AnimPresets.pulse(node)

func anim_fade_in(node: Control, duration: float = 0.2) -> Tween:
	return _AnimPresets.fade_in(node, duration)

func anim_fade_out(node: Control, duration: float = 0.2) -> Tween:
	return _AnimPresets.fade_out(node, duration)

func anim_stagger_fade(parent: Node) -> UIFlowSequencer:
	return _AnimPresets.stagger_fade_in(parent)


# ── Binding shortcuts ────────────────────────────────────────────────────────

func bind_signal(node: Node, prop_name: StringName, sig: Signal) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_signal(node, prop_name, sig)

func bind_signal_t(node: Node, prop_name: StringName, sig: Signal, transform: Callable) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_signal_t(node, prop_name, sig, transform)

func bind_visible(node: Node, sig: Signal, predicate: Callable) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_visible(node, sig, predicate)

func bind_format(node: Node, prop_name: StringName, sig: Signal, format: String) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_format(node, prop_name, sig, format)

func bind_slider(slider: Range, sig: Signal, setter: Callable) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_slider(slider, sig, setter)


## Bind an array signal to a UI template list.
## Automatically creates/updates/destroys instances when the array changes.
## Optionally provide a key function for stable item identity (preserves instances across reordering).
##
## Example:
## [codeblock]
## var binder = UIFlow.bind_list(
##     $GridContainer,
##     player_data.inventory_changed,
##     preload("res://item_slot.tscn"),
##     func(slot, item, index): slot.setup(item)
## )
## # Later: binder.unbind()
## [/codeblock]
const _ListBinderClass = preload("res://addons/ui_flow/core/ui_flow_list_binder.gd")

func bind_list(container: Node, sig: Signal, template: PackedScene, binder: Callable, key_func: Callable = Callable()):
	return _ListBinderClass.new(container, sig, template, binder, key_func)


# ── Input shortcuts ──────────────────────────────────────────────────────────

## Set the default focus node.
func set_default_focus(node: Control) -> void:
	FlowInput.set_default_focus(node)


# ── Theme shortcuts ──────────────────────────────────────────────────────────

func get_theme() -> UIFlowTheme:
	return ThemeHelper.get_current()

func apply_theme(theme: UIFlowTheme) -> void:
	ThemeHelper.apply_theme(theme)
	_apply_theme_to_container()

func apply_builtin_theme(name: String) -> void:
	ThemeHelper.apply_builtin(name)
	_apply_theme_to_container()

func get_color(slot: UIFlowTheme.ColorSlot) -> Color:
	return ThemeHelper.get_color(slot)

func set_color(slot: UIFlowTheme.ColorSlot, color: Color) -> void:
	ThemeHelper.set_color(slot, color)

func get_font_size(size_name: String) -> int:
	return ThemeHelper.get_font_size(size_name)

func get_spacing(size_name: String) -> int:
	return ThemeHelper.get_spacing(size_name)

func get_radius(size_name: String) -> int:
	return ThemeHelper.get_radius(size_name)


func _apply_theme_to_container() -> void:
	if _page_container == null:
		return
	var uiflow_theme: UIFlowTheme = ThemeHelper.get_current()
	if uiflow_theme == null:
		return
	_page_container.theme = uiflow_theme.build_godot_theme()
