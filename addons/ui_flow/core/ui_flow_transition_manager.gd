## Manages transition presets and plays transitions on UI nodes.
class_name UIFlowTransitionManager extends RefCounted

var _presets: Dictionary = {} # UIFlowTransitionType.Type -> UIFlowTransitionBase
var _default_type: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE
var _default_duration: float = 0.3


func _init() -> void:
	_register_defaults()


func _register_defaults() -> void:
	_presets[UIFlowTransitionType.Type.NONE] = UIFlowTransitionNone.new()
	_presets[UIFlowTransitionType.Type.FADE] = UIFlowTransitionFade.new(_default_duration)
	_presets[UIFlowTransitionType.Type.SLIDE_LEFT] = UIFlowTransitionSlideLeft.new(_default_duration)
	_presets[UIFlowTransitionType.Type.SLIDE_RIGHT] = UIFlowTransitionSlideRight.new(_default_duration)
	_presets[UIFlowTransitionType.Type.SLIDE_UP] = UIFlowTransitionSlideUp.new(_default_duration)
	_presets[UIFlowTransitionType.Type.SLIDE_DOWN] = UIFlowTransitionSlideDown.new(_default_duration)
	_presets[UIFlowTransitionType.Type.SCALE] = UIFlowTransitionScale.new(_default_duration)


## Get a preset transition by type.
func get_preset(type: UIFlowTransitionType.Type) -> UIFlowTransitionBase:
	if _presets.has(type):
		return _presets[type]
	return _presets[UIFlowTransitionType.Type.NONE]


## Get the default transition.
func default_transition() -> UIFlowTransitionBase:
	return get_preset(_default_type)


## Set the default transition type and duration.
func set_default(type: UIFlowTransitionType.Type, duration: float = 0.3) -> void:
	_default_type = type
	_default_duration = duration
	# Update existing presets that use the default duration
	if _presets.has(type):
		var preset: UIFlowTransitionBase = _presets[type]
		if "duration" in preset:
			preset.duration = duration


## Register a custom transition preset.
func register_custom(name: String, transition: UIFlowTransitionBase) -> void:
	# Custom transitions are stored by string name
	_presets[name] = transition


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


## Instantly hide a node (no animation, used when a new page covers it).
func play_exit_instant(node: Control) -> void:
	node.visible = false
