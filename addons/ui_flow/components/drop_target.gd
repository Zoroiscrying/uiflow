## UIFlowDropTarget — marks a Control as a drop destination.
##
## Attach as a child of any Control to make it a drop target.
##
## Usage:
## [codeblock]
## var target = UIFlowDropTarget.new()
## target.on_drop.connect(func(data): handle_drop(data))
## target.can_drop_check = func(data): return data.type == "weapon"
## $Slot.add_child(target)
## [/codeblock]
class_name UIFlowDropTarget extends Control

## Emitted when data is dropped on this target.
signal on_drop(data: Variant)

## Optional: callable to check if drop is allowed.
## Receives data, returns bool.
var can_drop_check: Callable = Callable()

## Highlight color when a valid drag is hovering.
@export var highlight_color: Color = Color(0.3, 0.7, 0.3, 0.3)

var _highlight: ColorRect


func _ready() -> void:
	add_to_group("uiflow_drop_target")
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Create highlight overlay
	_highlight = ColorRect.new()
	_highlight.set_anchors_preset(Control.PRESET_FULL_RECT)
	_highlight.color = highlight_color
	_highlight.visible = false
	_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_highlight)


## Check if this target accepts the given data.
func can_drop(data: Variant) -> bool:
	if can_drop_check.is_valid():
		return can_drop_check.call(data)
	return true


## Show highlight when valid drag hovers.
func show_highlight() -> void:
	if _highlight:
		_highlight.visible = true


## Hide highlight.
func hide_highlight() -> void:
	if _highlight:
		_highlight.visible = false
