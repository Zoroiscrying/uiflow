## UI input action definitions for UIFlow.
## Maps abstract UI actions to Godot Input Actions.
class_name UIFlowAction

## Abstract UI actions.
enum Action {
	CONFIRM,
	CANCEL,
	NAVIGATE_UP,
	NAVIGATE_DOWN,
	NAVIGATE_LEFT,
	NAVIGATE_RIGHT,
}

## Default Godot Input Action mappings.
const DEFAULT_MAPPINGS: Dictionary = {
	Action.CONFIRM: &"ui_accept",
	Action.CANCEL: &"ui_cancel",
	Action.NAVIGATE_UP: &"ui_up",
	Action.NAVIGATE_DOWN: &"ui_down",
	Action.NAVIGATE_LEFT: &"ui_left",
	Action.NAVIGATE_RIGHT: &"ui_right",
}

## Get the Godot Input Action name for a UIFlow action.
static func get_action_name(action: Action) -> StringName:
	return DEFAULT_MAPPINGS.get(action, &"")

## Human-readable names.
static func get_name(action: Action) -> String:
	match action:
		Action.CONFIRM: return "Confirm"
		Action.CANCEL: return "Cancel"
		Action.NAVIGATE_UP: return "Navigate Up"
		Action.NAVIGATE_DOWN: return "Navigate Down"
		Action.NAVIGATE_LEFT: return "Navigate Left"
		Action.NAVIGATE_RIGHT: return "Navigate Right"
		_: return "Unknown"
