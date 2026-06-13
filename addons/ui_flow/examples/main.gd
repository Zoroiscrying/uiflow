## Main entry point — UIFlow Free Demo.
## Showcases core UIFlow features: navigation, data binding, transitions, components, themes.
extends Control

const DemoHub = preload("res://addons/ui_flow/examples/free_demo/demo_hub.gd")


func _ready() -> void:
	await get_tree().process_frame
	UIFlow.push(DemoHub)
