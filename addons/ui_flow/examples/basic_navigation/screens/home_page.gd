## Example home page — demonstrates UIFlowPage lifecycle and navigation.
class_name HomePage extends UIFlowPage

func _ready() -> void:
	$VBox/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBox/ShopButton.pressed.connect(_on_shop_pressed)


func _on_opened(_data: Dictionary = {}) -> void:
	print("[HomePage] Enter")


func _on_closed() -> void:
	print("[HomePage] Exit")


func _on_hidden() -> void:
	print("[HomePage] Pause")


func _on_shown() -> void:
	print("[HomePage] Resume")


func _on_settings_pressed() -> void:
	UIFlow.push(SettingsPage, {})


func _on_shop_pressed() -> void:
	# Push and get reference to the page instance
	var shop: ShopPage = UIFlow.push(ShopPage, {}) as ShopPage
	if shop:
		shop.set_npc_id(1)  # Call custom methods directly
