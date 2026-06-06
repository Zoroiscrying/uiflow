## Example shop page — demonstrates receiving data from push().
extends UIFlowPage

func _on_enter(data: Dictionary = {}) -> void:
	print("[ShopPage] Enter with data: ", data)
	var npc_id: int = data.get("npc_id", 0)
	$VBox/NpcLabel.text = "NPC ID: %d" % npc_id


func _on_exit() -> void:
	print("[ShopPage] Exit")


func _ready() -> void:
	$VBox/BackButton.pressed.connect(func(): UIFlow.pop())
