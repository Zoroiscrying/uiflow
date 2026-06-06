## A route definition resource for UIFlow navigation.
## Use this to define routes in Inspector or as .tres files (Pro feature).
@tool
class_name UIFlowRoute extends Resource

@export var page_class: GDScript
@export var scene: PackedScene
@export var transition: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE
@export var transition_duration: float = 0.3
