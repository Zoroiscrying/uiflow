## Global UIFlow configuration resource.
## Create one of these in your project to customize UIFlow behavior.
## Settings can also be configured via Project Settings → UIFlow.
@tool
class_name UIFlowConfig extends Resource

@export var scene_directory: String = "res://UIScene/"
@export var default_transition: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE
@export var default_transition_duration: float = 0.3
@export var back_action: StringName = &"ui_cancel"
@export var auto_focus_on_push: bool = true
@export var restore_focus_on_pop: bool = true

## Maximum navigation stack depth before pushing new pages is blocked.
## Prevents accidental memory leaks from unbounded push loops.
@export_range(1, 200, 1) var max_stack_depth: int = 50

## If true, pressing back on a modal page without an _on_back handler will pop it.
## If false, modal pages swallow the back input and stay open.
@export var modal_close_on_back: bool = true

## Default theme name applied on startup ("dark", "light", or a custom registered name).
@export var default_theme_name: String = "dark"
