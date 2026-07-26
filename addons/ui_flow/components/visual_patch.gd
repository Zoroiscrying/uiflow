## Optional visual property patch for UIFlowChildrenSwitcher.
##
## Only fields with matching [code]set_*=true[/code] are applied.
## Unset fields leave the target node unchanged.
class_name UIFlowVisualPatch extends Resource

@export_group("Visible")
@export var set_visible: bool = false
@export var visible: bool = true

@export_group("Modulate")
@export var set_modulate: bool = false
@export var modulate: Color = Color.WHITE

@export_group("Self Modulate")
@export var set_self_modulate: bool = false
@export var self_modulate: Color = Color.WHITE

@export_group("Scale")
@export var set_scale: bool = false
@export var scale: Vector2 = Vector2.ONE

@export_group("Disabled")
@export var set_disabled: bool = false
@export var disabled: bool = false

@export_group("Font Size")
@export var set_font_size: bool = false
@export var font_size: int = 16

@export_group("Custom Minimum Size")
@export var set_custom_minimum_size: bool = false
@export var custom_minimum_size: Vector2 = Vector2.ZERO


## True when at least one property override is enabled.
func has_any_override() -> bool:
	return (
		set_visible
		or set_modulate
		or set_self_modulate
		or set_scale
		or set_disabled
		or set_font_size
		or set_custom_minimum_size
	)
