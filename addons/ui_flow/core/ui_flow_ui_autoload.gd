## UIFlowUI — Middle-layer convenience components built on top of UIFlow core.
##
## Access via [code]UIFlowUI.Toast.show("message")[/code].
##
## This layer provides ready-to-use UI components (Toast, Confirm, Alert).
## Users can replace any component with a custom implementation:
## [codeblock]
## # Replace the default Toast with a custom one
## UIFlowUI.Toast = my_custom_toast
## [/codeblock]
extends Node

## Toast notification system. Replace with your own implementation.
var Toast: UIFlowToast

## Confirmation dialog. Replace with your own implementation.
var Confirm: UIFlowConfirmDialog

## Alert dialog. Replace with your own implementation.
var Alert: UIFlowAlertDialog

var _component_layer: CanvasLayer


func _ready() -> void:
	# Create component layer (above everything)
	_component_layer = CanvasLayer.new()
	_component_layer.name = "UIFlowComponentLayer"
	_component_layer.layer = 100
	add_child(_component_layer)

	_setup_defaults()


func _setup_defaults() -> void:
	# Toast
	Toast = UIFlowToast.new()
	Toast.name = "UIFlowToast"
	Toast.process_mode = Node.PROCESS_MODE_ALWAYS
	Toast.set_anchors_preset(Control.PRESET_FULL_RECT)
	Toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_component_layer.add_child(Toast)

	# Confirm
	Confirm = UIFlowConfirmDialog.new()
	Confirm.name = "UIFlowConfirm"
	Confirm.process_mode = Node.PROCESS_MODE_ALWAYS
	Confirm.set_anchors_preset(Control.PRESET_FULL_RECT)
	_component_layer.add_child(Confirm)

	# Alert
	Alert = UIFlowAlertDialog.new()
	Alert.name = "UIFlowAlert"
	Alert.process_mode = Node.PROCESS_MODE_ALWAYS
	Alert.set_anchors_preset(Control.PRESET_FULL_RECT)
	_component_layer.add_child(Alert)


## Replace the Toast implementation with a custom one.
func set_custom_toast(toast: UIFlowToast) -> void:
	if Toast and is_instance_valid(Toast):
		_component_layer.remove_child(Toast)
		Toast.queue_free()
	Toast = toast
	Toast.set_anchors_preset(Control.PRESET_FULL_RECT)
	_component_layer.add_child(Toast)


## Replace the Confirm implementation with a custom one.
func set_custom_confirm(confirm: UIFlowConfirmDialog) -> void:
	if Confirm and is_instance_valid(Confirm):
		_component_layer.remove_child(Confirm)
		Confirm.queue_free()
	Confirm = confirm
	Confirm.set_anchors_preset(Control.PRESET_FULL_RECT)
	_component_layer.add_child(Confirm)


## Replace the Alert implementation with a custom one.
func set_custom_alert(alert: UIFlowAlertDialog) -> void:
	if Alert and is_instance_valid(Alert):
		_component_layer.remove_child(Alert)
		Alert.queue_free()
	Alert = alert
	Alert.set_anchors_preset(Control.PRESET_FULL_RECT)
	_component_layer.add_child(Alert)
