## Simple loading page shown by push_async_with_loading while a scene loads.
##
## Implements the set_progress(float) protocol: the navigator forwards
## threaded load progress (0.0–1.0) while the target scene loads.
## Falls back to an animated "Loading..." label when no progress arrives
## (e.g. the scene was served from cache).
class_name AsyncLoadingPage extends UIFlowPage

@onready var _label: Label = $Center/Label
@onready var _bar: ProgressBar = $Center/ProgressBar
@onready var _timer: Timer = $Timer

var _dot_count: int = 0
var _received_progress: bool = false


func _ready() -> void:
	_update_dots()
	_timer.timeout.connect(_update_dots)


## Called by UIFlowNavigator while the target scene loads (0.0–1.0).
func set_progress(p: float) -> void:
	_received_progress = true
	_bar.value = p * 100.0
	_label.text = "Loading %d%%" % int(p * 100.0)


func _update_dots() -> void:
	if _received_progress:
		return
	_dot_count = (_dot_count + 1) % 4
	_label.text = "Loading" + ".".repeat(_dot_count)
