## Enum mapping for common UI tween properties, avoiding string-based property paths.
class_name UIFlowTweenProp

enum Prop {
	POSITION_X,
	POSITION_Y,
	POSITION,
	MODULATE_A,
	MODULATE,
	SCALE_X,
	SCALE_Y,
	SCALE,
	ROTATION,
	SIZE_X,
	SIZE_Y,
	SIZE,
}

## Convert enum to Godot property path string.
static func to_path(prop: Prop) -> String:
	match prop:
		Prop.POSITION_X: return "position:x"
		Prop.POSITION_Y: return "position:y"
		Prop.POSITION: return "position"
		Prop.MODULATE_A: return "modulate:a"
		Prop.MODULATE: return "modulate"
		Prop.SCALE_X: return "scale:x"
		Prop.SCALE_Y: return "scale:y"
		Prop.SCALE: return "scale"
		Prop.ROTATION: return "rotation"
		Prop.SIZE_X: return "size:x"
		Prop.SIZE_Y: return "size:y"
		Prop.SIZE: return "size"
		_: return ""
