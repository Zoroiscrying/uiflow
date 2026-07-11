## Simple loading page shown by push_async_with_loading while a scene loads.
class_name AsyncLoadingPage extends UIFlowPage

@onready var _label: Label = $Center/Label
@onready var _timer: Timer = $Timer

var _dot_count: int = 0


func _ready() -> void:
	_update_dots()
	_timer.timeout.connect(_update_dots)


func _update_dots() -> void:
	_dot_count = (_dot_count + 1) % 4
	_label.text = "Loading" + ".".repeat(_dot_count)
