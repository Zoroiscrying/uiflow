## Example home page — demonstrates UIFlowPage lifecycle and navigation.
class_name HomePage extends UIFlowPage

func _ready() -> void:
	$VBox/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBox/ShopButton.pressed.connect(_on_shop_pressed)


func _on_enter(_data: Dictionary = {}) -> void:
	print("[HomePage] Enter")


func _on_exit() -> void:
	print("[HomePage] Exit")


func _on_pause() -> void:
	print("[HomePage] Pause")


func _on_resume() -> void:
	print("[HomePage] Resume")


func _on_settings_pressed() -> void:
	UIFlow.push(SettingsPage, {}, UIFlowTransitionType.Type.SLIDE_LEFT)


func _on_shop_pressed() -> void:
	# Push and get reference to the page instance
	var shop: ShopPage = UIFlow.push(ShopPage, {}, UIFlowTransitionType.Type.FADE) as ShopPage
	if shop:
		shop.set_npc_id(1)  # Call custom methods directly
