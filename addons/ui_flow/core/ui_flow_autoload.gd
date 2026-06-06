## UIFlow — The main autoload singleton providing the unified API for UI management.
##
## Access via [code]UIFlow.method()[/code] from anywhere in your project.
##
## Example:
## [codeblock]
## UIFlow.push(SettingsPage)
## UIFlow.push(ShopPage, {"npc_id": 123})
## UIFlow.pop()
## UIFlow.Toast.show("Hello!")
## [/codeblock]
extends Node

# ── Sub-systems ──────────────────────────────────────────────────────────────

## Navigation operations (push/pop/replace).
var Router: UIFlowNavigator
## Scene resolution (class_name → PackedScene).
var Scenes: UIFlowSceneResolver
## Transition management (presets and playback).
var Transitions: UIFlowTransitionManager

# ── Components ───────────────────────────────────────────────────────────────

## Toast notification system.
var Toast: UIFlowToast
## Confirmation dialog.
var Confirm: UIFlowConfirmDialog
## Alert dialog.
var Alert: UIFlowAlertDialog

# ── Internal ─────────────────────────────────────────────────────────────────

var _page_container: Control
var _component_layer: CanvasLayer


func _ready() -> void:
	# Create page container (full-screen Control for pages)
	_page_container = Control.new()
	_page_container.name = "UIFlowPageContainer"
	_page_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_page_container)

	# Create component layer (above everything)
	_component_layer = CanvasLayer.new()
	_component_layer.name = "UIFlowComponentLayer"
	_component_layer.layer = 100
	add_child(_component_layer)

	# Initialize sub-systems
	Scenes = UIFlowSceneResolver.new()
	Transitions = UIFlowTransitionManager.new()

	Router = UIFlowNavigator.new()
	Router.name = "UIFlowNavigator"
	add_child(Router)
	Router.setup(_page_container, Scenes, Transitions)

	# Initialize components
	_setup_components()


func _setup_components() -> void:
	# Toast
	Toast = UIFlowToast.new()
	Toast.name = "UIFlowToast"
	Toast.set_anchors_preset(Control.PRESET_FULL_RECT)
	Toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_component_layer.add_child(Toast)

	# Confirm
	Confirm = UIFlowConfirmDialog.new()
	Confirm.name = "UIFlowConfirm"
	Confirm.set_anchors_preset(Control.PRESET_FULL_RECT)
	_component_layer.add_child(Confirm)

	# Alert
	Alert = UIFlowAlertDialog.new()
	Alert.name = "UIFlowAlert"
	Alert.set_anchors_preset(Control.PRESET_FULL_RECT)
	_component_layer.add_child(Alert)


# ── Router shortcuts ─────────────────────────────────────────────────────────

## Push a page onto the navigation stack.
## Returns the page instance for immediate custom initialization.
##
## Example:
## [codeblock]
## var page: SettingsPage = UIFlow.push(SettingsPage) as SettingsPage
## page.setup(my_config)
## [/codeblock]
func push(page_class: GDScript, data: Dictionary = {}, transition = null) -> Control:
	return Router.push(page_class, data, transition)


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

## Set the default transition type and duration.
func set_default_transition(type: UIFlowTransitionType.Type, duration: float = 0.3) -> void:
	Transitions.set_default(type, duration)


## Register a custom transition.
func register_transition(name: String, transition: UIFlowTransitionBase) -> void:
	Transitions.register_custom(name, transition)


## Create a transition instance with custom parameters.
func create_transition(type: UIFlowTransitionType.Type, duration: float, ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR) -> UIFlowTransitionBase:
	match type:
		UIFlowTransitionType.Type.FADE:
			return UIFlowTransitionFade.new(duration, ease, trans)
		UIFlowTransitionType.Type.SLIDE_LEFT:
			return UIFlowTransitionSlideLeft.new(duration, ease, trans)
		UIFlowTransitionType.Type.SLIDE_RIGHT:
			return UIFlowTransitionSlideRight.new(duration, ease, trans)
		UIFlowTransitionType.Type.SCALE:
			return UIFlowTransitionScale.new(duration, ease, trans)
		_:
			return UIFlowTransitionNone.new()


# ── Animation shortcuts ──────────────────────────────────────────────────────

## Animate a property on a node using TweenProp enum.
## Returns the Tween for chaining or awaiting.
##
## Example:
## [codeblock]
## UIFlow.animate($Panel, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.3)
## await UIFlow.animate($Panel, UIFlowTweenProp.Prop.POSITION_X, -400, 0, 0.4).finished
## [/codeblock]
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
