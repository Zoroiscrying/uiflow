## Example main script — demonstrates UIFlow basic navigation.
##
## Attach this to your main scene. It pushes the HomePage as the initial screen.
extends Control

func _ready() -> void:
	# Push the home page as the initial screen
	UIFlow.push(HomePage, {})
