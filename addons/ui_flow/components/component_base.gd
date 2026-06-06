## Base class for UIFlow reusable components.
##
## Components are UI elements managed by UIFlow with consistent lifecycle and styling.
## Extend this class for custom components.
##
## Lifecycle:
## - [code]_component_ready()[/code]: Called once when the component is first initialized.
## - [code]_component_show()[/code]: Called each time the component becomes visible.
## - [code]_component_hide()[/code]: Called each time the component is hidden.
class_name UIFlowComponent extends Control

var _initialized: bool = false


func _ready() -> void:
	if not _initialized:
		_initialized = true
		_component_ready()


## Override: called once when the component is first initialized.
func _component_ready() -> void:
	pass


## Override: called each time the component becomes visible.
func _component_show() -> void:
	pass


## Override: called each time the component is hidden.
func _component_hide() -> void:
	pass


## Show the component with optional animation.
func show_component() -> void:
	visible = true
	_component_show()


## Hide the component with optional animation.
func hide_component() -> void:
	visible = false
	_component_hide()
