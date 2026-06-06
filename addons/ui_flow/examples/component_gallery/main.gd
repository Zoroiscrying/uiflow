## Component Gallery — demonstrates Toast, Confirm, Alert, and all transitions.
extends Control

func _ready() -> void:
	UIFlow.push(GalleryPage, {}, UIFlowTransitionType.Type.NONE)
