## Predefined transition types for UIFlow.
class_name UIFlowTransitionType

enum Type {
	NONE,
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_UP,
	SLIDE_DOWN,
	SCALE,
}

## Human-readable names for each transition type.
static func get_name(type: Type) -> String:
	match type:
		Type.NONE: return "None"
		Type.FADE: return "Fade"
		Type.SLIDE_LEFT: return "Slide Left"
		Type.SLIDE_RIGHT: return "Slide Right"
		Type.SLIDE_UP: return "Slide Up"
		Type.SLIDE_DOWN: return "Slide Down"
		Type.SCALE: return "Scale"
		_: return "Unknown"
