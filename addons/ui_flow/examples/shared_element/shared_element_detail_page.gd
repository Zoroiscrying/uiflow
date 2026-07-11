class_name SharedElementDetailPage extends UIFlowPage

@onready var _title: Label = $Title
@onready var _back_button: Button = $BackButton


func _on_created(data: Variant = null) -> void:
	if data is Dictionary:
		if data.has("effect"):
			var effect := data["effect"] as UIFlowTransitionEffect
			enter_effect = effect
			exit_effect = effect
		if data.has("title"):
			var title_label := get_node_or_null("Title") as Label
			if title_label != null:
				title_label.text = data["title"]
		var icon_name: StringName = data.get("icon", &"")
		for child in get_children():
			if child.name.ends_with("Icon"):
				child.visible = (String(child.name) == String(icon_name))


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_back_button)
