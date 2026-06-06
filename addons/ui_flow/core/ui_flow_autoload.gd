## UIFlow — The main autoload singleton providing the unified API for UI management.
##
## Access via [code]UIFlow.method()[/code] from anywhere in your project.
##
## Example:
## [codeblock]
## UIFlow.push(SettingsPage)
## UIFlow.push(ShopPage, {"npc_id": 123})
## UIFlow.pop()
## [/codeblock]
##
## For convenience components (Toast, Confirm, Alert), use [code]UIFlowUI[/code]:
## [codeblock]
## UIFlowUI.Toast.show("Hello!")
## UIFlowUI.Confirm.show("Title", "Message", on_confirm)
## [/codeblock]
extends Node

# ── Sub-systems ──────────────────────────────────────────────────────────────

## Navigation operations (push/pop/replace).
var Router: UIFlowNavigator
## Scene resolution (class_name → PackedScene).
var Scenes: UIFlowSceneResolver
## Transition management (presets and playback).
var Transitions: UIFlowTransitionManager
## Input handling and focus management.
var FlowInput: UIFlowInputHandler
## Theme utilities and named color palette.
var ThemeHelper: UIFlowThemeHelper

# ── Internal ─────────────────────────────────────────────────────────────────

var _page_container: Control


var _custom_ui_root: Control = null


func _ready() -> void:
	# Initialize sub-systems
	Scenes = UIFlowSceneResolver.new()
	Transitions = UIFlowTransitionManager.new()
	ThemeHelper = UIFlowThemeHelper.new()

	Router = UIFlowNavigator.new()
	Router.name = "UIFlowNavigator"
	add_child(Router)

	FlowInput = UIFlowInputHandler.new()
	FlowInput.name = "UIFlowInputHandler"
	add_child(FlowInput)
	FlowInput.back_pressed.connect(_on_back_pressed)


## Set a custom Control node as the UI root for pages.
## Call this BEFORE pushing the first page.
## If not called, UIFlow creates its own container.
func set_ui_root(root: Control) -> void:
	_custom_ui_root = root
	_page_container = root
	Router.setup(_page_container, Scenes, Transitions)
	_apply_theme_to_container()


func _ensure_page_container() -> void:
	if _page_container:
		return

	if _custom_ui_root:
		_page_container = _custom_ui_root
	else:
		# Auto-create — add Control directly to the autoload node.
		# In Godot, Controls render on top of 3D content by default.
		_page_container = Control.new()
		_page_container.name = "UIFlowPageContainer"
		_page_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		_page_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_page_container.grow_vertical = Control.GROW_DIRECTION_BOTH
		add_child(_page_container)

	Router.setup(_page_container, Scenes, Transitions)
	_apply_theme_to_container()


func _on_back_pressed() -> void:
	if stack_depth() > 0:
		pop()


# ── Router shortcuts ─────────────────────────────────────────────────────────

## Push a page onto the navigation stack.
## Returns the page instance for immediate custom initialization.
##
## Example:
## [codeblock]
## var page: SettingsPage = UIFlow.push(SettingsPage) as SettingsPage
## page.setup(my_config)
## [/codeblock]
func push(page_class: GDScript, data: Dictionary = {}, transition = null, page_theme: UIFlowTheme = null) -> Control:
	_ensure_page_container()
	return Router.push(page_class, data, transition, page_theme)


## Pop the top page off the stack.
func pop(transition = null) -> void:
	Router.pop(transition)


## Replace the top page with a new one (doesn't increase stack depth).
## Returns the new page instance.
func replace(page_class: GDScript, data: Dictionary = {}, transition = null) -> Control:
	return Router.replace(page_class, data, transition)


## Remove all pages.
func pop_to_root(transition = null) -> void:
	Router.pop_to_root(transition)


## Get the class of the current top page.
func current_page() -> GDScript:
	return Router.current_page_class()


## Get the current stack depth.
func stack_depth() -> int:
	return Router.depth()


## Get the full navigation path as an array of class names.
func navigation_path() -> Array[StringName]:
	return Router.navigation_path()


## Find a page instance in the stack by its class.
func get_page(page_class: GDScript) -> Control:
	return Router.get_page(page_class)


## Check if a page of the given class is currently in the stack.
func has_page(page_class: GDScript) -> bool:
	return Router.has_page(page_class)


# ── Scene registration shortcuts ─────────────────────────────────────────────

## Register a custom scene mapping for a page class.
func register_scene(page_class: GDScript, scene: PackedScene) -> void:
	Scenes.register_scene(page_class, scene)


# ── Transition shortcuts ─────────────────────────────────────────────────────

## Set the default transition type.
func set_default_transition(type: UIFlowTransitionType.Type, _duration: float = 0.3) -> void:
	Transitions.set_default(type, _duration)


## Get a preset UIFlowTransition resource by type.
## Returns the .tres resource — edit its properties to customize.
func get_transition_preset(type: UIFlowTransitionType.Type) -> UIFlowTransition:
	return Transitions.get_preset_resource(type)


## Register a custom transition resource by name.
func register_transition(name: String, transition: UIFlowTransition) -> void:
	Transitions.register_custom(name, transition)


## Create a transition instance with inline parameters.
func create_transition(type: UIFlowTransitionType.Type, duration: float, ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR) -> UIFlowTransitionBase:
	return Transitions.create_instance(type, duration, ease, trans)


## Create a transition instance from a UIFlowTransition resource.
func create_transition_from(res: UIFlowTransition) -> UIFlowTransitionBase:
	return Transitions.create_instance_from_resource(res)


# ── Animation shortcuts ──────────────────────────────────────────────────────

## Animate a property on a node using TweenProp enum.
## Returns the Tween for chaining or awaiting.
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


## Animate using a raw Godot property path string.
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


## Create a sequencer for multi-element animations.
func sequencer() -> UIFlowSequencer:
	return UIFlowAnimator.sequencer()


# ── Binding shortcuts ────────────────────────────────────────────────────────

## Bind a Signal to a property on a node.
func bind_signal(node: Node, prop_name: StringName, sig: Signal) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_signal(node, prop_name, sig)


## Bind a Signal to a property with a transform function.
func bind_signal_t(node: Node, prop_name: StringName, sig: Signal, transform: Callable) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_signal_t(node, prop_name, sig, transform)


## Bind a Signal to node visibility with a predicate.
func bind_visible(node: Node, sig: Signal, predicate: Callable) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_visible(node, sig, predicate)


## Bind a Signal to a property with a format string.
func bind_format(node: Node, prop_name: StringName, sig: Signal, format: String) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_format(node, prop_name, sig, format)


## Two-way bind a Slider to a Signal and setter.
func bind_slider(slider: Range, sig: Signal, setter: Callable) -> UIFlowBindUtils.UIFlowBinding:
	return UIFlowBindUtils.bind_slider(slider, sig, setter)


# ── Input shortcuts ──────────────────────────────────────────────────────────

## Set a custom back/cancel callback.
func set_back_callback(callback: Callable) -> void:
	FlowInput.set_custom_callback(callback)


## Reset back behavior to default (auto-pop).
func reset_back_callback() -> void:
	FlowInput.reset_callback()


## Set the default focus node for the current page.
func set_default_focus(node: Control) -> void:
	FlowInput.set_default_focus(node)


## Enable or disable back/cancel handling.
func set_back_enabled(value: bool) -> void:
	FlowInput.set_enabled(value)


# ── Theme shortcuts ──────────────────────────────────────────────────────────

## Get the current active UIFlowTheme resource.
func get_theme() -> UIFlowTheme:
	return ThemeHelper.get_current()


## Apply a UIFlowTheme resource as the active theme.
## Automatically generates a Godot Theme and applies it to all UI containers.
##
## Example:
## [codeblock]
## UIFlow.apply_theme(preload("res://addons/ui_flow/themes/dark.tres"))
## UIFlow.apply_theme(preload("res://my_custom_theme.tres"))
## [/codeblock]
func apply_theme(theme: UIFlowTheme) -> void:
	ThemeHelper.apply_theme(theme)
	_apply_theme_to_container()


## Apply a built-in theme by name ("dark" or "light").
func apply_builtin_theme(name: String) -> void:
	ThemeHelper.apply_builtin(name)
	_apply_theme_to_container()


func _apply_theme_to_container() -> void:
	var uiflow_theme: UIFlowTheme = ThemeHelper.get_current()
	if uiflow_theme == null:
		return

	# Build Godot Theme from UIFlowTheme and apply to page container
	var godot_theme: Theme = uiflow_theme.build_godot_theme()
	_page_container.theme = godot_theme

	# Also apply to UIFlowUI component layer if it exists
	var ui_layer: CanvasLayer = get_node_or_null("/root/UIFlowUI/UIFlowComponentLayer")
	if ui_layer:
		for child in ui_layer.get_children():
			if child is Control:
				child.theme = godot_theme


## Get a named color from the current theme.
func get_color(slot: UIFlowTheme.ColorSlot) -> Color:
	return ThemeHelper.get_color(slot)


## Set a named color on the current theme.
func set_color(slot: UIFlowTheme.ColorSlot, color: Color) -> void:
	ThemeHelper.set_color(slot, color)


## Get a font size from the current theme.
## Valid sizes: "title", "heading", "body", "small"
func get_font_size(size_name: String) -> int:
	return ThemeHelper.get_font_size(size_name)


## Get a spacing value from the current theme.
## Valid sizes: "xs", "sm", "md", "lg", "xl"
func get_spacing(size_name: String) -> int:
	return ThemeHelper.get_spacing(size_name)


## Get a border radius from the current theme.
## Valid sizes: "sm", "md", "lg"
func get_radius(size_name: String) -> int:
	return ThemeHelper.get_radius(size_name)
