## Standalone Gamepad UI demo scene — pushes GamepadDemoPage on start.
extends Control


func _ready() -> void:
	await get_tree().process_frame
	UIFlow.push(GamepadDemoPage)
