## Target page used by the Timeline & Async Loading demo.
## Receives an optional [code]enter_effect[/code] and title via push data.
class_name TimelineAsyncTargetPage extends UIFlowPage

@onready var _back_button: Button = $Center/BackButton


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_created(data: Variant = null) -> void:
	var dict := _as_dict(data)
	$Center/NameLabel.text = dict.get("title", "Target")


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_back_button)
