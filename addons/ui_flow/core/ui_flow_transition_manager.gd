## Manages transition presets loaded from .tres Resource files.
##
## Built-in presets are loaded from transitions/presets/.
## Users can register custom presets or override built-in ones.
class_name UIFlowTransitionManager extends RefCounted

## Preset .tres files directory.
const PRESETS_DIR := "res://addons/ui_flow/transitions/presets/"

## Built-in preset file names mapped to transition types.
const PRESET_FILES: Dictionary = {
	UIFlowTransitionType.Type.NONE: "none.tres",
	UIFlowTransitionType.Type.FADE: "fade.tres",
	UIFlowTransitionType.Type.SLIDE_LEFT: "slide_left.tres",
	UIFlowTransitionType.Type.SLIDE_RIGHT: "slide_right.tres",
	UIFlowTransitionType.Type.SLIDE_UP: "slide_up.tres",
	UIFlowTransitionType.Type.SLIDE_DOWN: "slide_down.tres",
	UIFlowTransitionType.Type.SCALE: "scale.tres",
}

var _presets: Dictionary = {} # UIFlowTransitionType.Type -> UIFlowTransition (Resource)
var _custom_presets: Dictionary = {} # String -> UIFlowTransition (Resource)
var _default_type: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE


func _init() -> void:
	_load_builtin_presets()


func _load_builtin_presets() -> void:
	for type_key: UIFlowTransitionType.Type in PRESET_FILES:
		var path: String = PRESETS_DIR + PRESET_FILES[type_key]
		if ResourceLoader.exists(path):
			var res: UIFlowTransition = load(path) as UIFlowTransition
			if res:
				_presets[type_key] = res
		else:
			push_warning("UIFlow: Missing preset file: %s" % path)


## Get a UIFlowTransition resource by type.
func get_preset_resource(type: UIFlowTransitionType.Type) -> UIFlowTransition:
	if _presets.has(type):
		return _presets[type]
	return _presets.get(UIFlowTransitionType.Type.NONE, null)


## Get a UIFlowTransitionBase instance ready for playback.
func get_preset(type: UIFlowTransitionType.Type) -> UIFlowTransitionBase:
	var res: UIFlowTransition = get_preset_resource(type)
	if res:
		return res.create_instance()
	return UIFlowTransitionNone.new()


## Get the default transition instance.
func default_transition() -> UIFlowTransitionBase:
	return get_preset(_default_type)


## Set the default transition type.
func set_default(type: UIFlowTransitionType.Type, _duration: float = 0.3) -> void:
	_default_type = type


## Register a custom transition preset by name.
## Users can create a UIFlowTransition .tres and register it.
func register_custom(name: String, transition: UIFlowTransition) -> void:
	_custom_presets[name] = transition


## Get a custom preset by name.
func get_custom_preset(name: String) -> UIFlowTransition:
	return _custom_presets.get(name, null)


## Create a UIFlowTransitionBase instance from a UIFlowTransition resource.
func create_instance_from_resource(res: UIFlowTransition) -> UIFlowTransitionBase:
	if res:
		return res.create_instance()
	return UIFlowTransitionNone.new()


## Create a UIFlowTransitionBase instance with inline parameters.
func create_instance(
	type: UIFlowTransitionType.Type,
	duration: float,
	ease_type: Tween.EaseType = Tween.EASE_IN_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_LINEAR
) -> UIFlowTransitionBase:
	var res := UIFlowTransition.new()
	res.type = type
	res.duration = duration
	res.ease_type = ease_type
	res.trans_type = trans_type
	return res.create_instance()


## Play enter animation on a node.
func play_enter(node: Control, transition: UIFlowTransitionBase, callback: Callable = Callable()) -> void:
	if transition:
		transition.play_enter(node, callback)
	else:
		node.visible = true
		if callback.is_valid():
			callback.call()


## Play exit animation on a node.
func play_exit(node: Control, transition: UIFlowTransitionBase, callback: Callable = Callable()) -> void:
	if transition:
		transition.play_exit(node, callback)
	else:
		if callback.is_valid():
			callback.call()


## Instantly hide a node (no animation).
func play_exit_instant(node: Control) -> void:
	node.visible = false
