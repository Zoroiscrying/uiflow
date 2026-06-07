## Example shop page — demonstrates receiving data and custom methods.
class_name BasicShopPage extends UIFlowPage

var _npc_id: int = 0


## Custom method — called by the caller after push() for immediate setup.
func set_npc_id(id: int) -> void:
	_npc_id = id
	$VBox/NpcLabel.text = "NPC ID: %d" % id


func _on_opened(data: Dictionary = {}) -> void:
	print("[ShopPage] Enter with data: ", data)
	# Also support data passed via push()
	if data.has("npc_id"):
		set_npc_id(data["npc_id"])


func _on_closed() -> void:
	print("[ShopPage] Exit")


func _ready() -> void:
	$VBox/BackButton.pressed.connect(func(): UIFlow.pop())
