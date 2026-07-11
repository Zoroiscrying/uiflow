## Target page loaded asynchronously by the Timeline & Async Loading demo.
class_name AsyncTargetPage extends UIFlowPage

@onready var _back_button: Button = $Center/BackButton


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_created(data: Variant = null) -> void:
	var dict := _as_dict(data)
	$Center/NameLabel.text = dict.get("title", "Async Target")


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_back_button)
