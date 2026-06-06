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
extends Node

# ── Sub-systems ──────────────────────────────────────────────────────────────

## Navigation operations (push/pop/replace).
var Router: UIFlowNavigator
## Scene resolution (class_name → PackedScene).
var Scenes: UIFlowSceneResolver
## Transition management (presets and playback).
var Transitions: UIFlowTransitionManager

# ── Signals ──────────────────────────────────────────────────────────────────

## Event Bus — define your game events as signals here.
## Example: [code]signal player_died[/code] in a custom EventBus script,
## or use this node directly for simple projects.

# ── Internal ─────────────────────────────────────────────────────────────────

var _page_container: Control


func _ready() -> void:
	# Create page container (full-screen Control for pages)
	_page_container = Control.new()
	_page_container.name = "UIFlowPageContainer"
	_page_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_page_container)

	# Initialize sub-systems
	Scenes = UIFlowSceneResolver.new()
	Transitions = UIFlowTransitionManager.new()

	Router = UIFlowNavigator.new()
	Router.name = "UIFlowNavigator"
	add_child(Router)
	Router.setup(_page_container, Scenes, Transitions)


# ── Router shortcuts ─────────────────────────────────────────────────────────

## Push a page onto the navigation stack.
## [param page_class] is the GDScript class (e.g. SettingsPage).
## [param data] is passed to the page's [code]_on_enter()[/code] callback.
## [param transition] optionally overrides the default transition (a preset type or custom instance).
func push(page_class: GDScript, data: Dictionary = {}, transition = null) -> void:
	Router.push(page_class, data, transition)


## Pop the top page off the stack.
func pop(transition = null) -> void:
	Router.pop(transition)


## Replace the top page with a new one (doesn't increase stack depth).
func replace(page_class: GDScript, data: Dictionary = {}, transition = null) -> void:
	Router.replace(page_class, data, transition)


## Remove all pages and optionally push a new root page.
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


# ── Scene registration shortcuts ─────────────────────────────────────────────

## Register a custom scene mapping for a page class.
## Use when the scene file doesn't follow the naming convention.
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
