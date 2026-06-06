## Global UIFlow configuration resource.
## Create one of these in your project to customize UIFlow behavior.
@tool
class_name UIFlowConfig extends Resource

@export var scene_directory: String = "res://UIScene/"
@export var default_transition: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE
@export var default_transition_duration: float = 0.3
@export var back_action: StringName = &"ui_cancel"
@export var auto_focus_on_push: bool = true
@export var restore_focus_on_pop: bool = true
