## Shared overlay host so floating UI draws above UIFlowPageLayer (10).
class_name UIFlowOverlayHost extends RefCounted

const OVERLAY_LAYER := 100
const META_LAYER := &"_uiflow_overlay_layer"


## Ensures [param control] lives under a root CanvasLayer at [constant OVERLAY_LAYER].
static func ensure_on_overlay(control: Control) -> void:
	if control == null:
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var layer: CanvasLayer = null
	if control.has_meta(META_LAYER):
		layer = control.get_meta(META_LAYER) as CanvasLayer
	if layer == null or not is_instance_valid(layer):
		layer = CanvasLayer.new()
		layer.layer = OVERLAY_LAYER
		layer.name = "UIFlowOverlayLayer"
		tree.root.add_child(layer)
		control.set_meta(META_LAYER, layer)
	if control.get_parent() != layer:
		var gp := control.global_position
		if control.get_parent() != null:
			control.get_parent().remove_child(control)
		layer.add_child(control)
		control.global_position = gp


## Removes overlay ownership metadata (does not free the layer if shared).
static func clear_overlay_meta(control: Control) -> void:
	if control != null and control.has_meta(META_LAYER):
		control.remove_meta(META_LAYER)
