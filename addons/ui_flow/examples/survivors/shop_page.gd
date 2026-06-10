## Shop Page — buy/sell items with inventory integration.
class_name SurvivorsShopPage extends UIFlowPage

@export var inventory_data: InventoryData

@onready var _close_button: Button = $Panel/VBox/Header/CloseButton
@onready var _gold_label: Label = $Panel/VBox/Header/GoldLabel
@onready var _item_list: VBoxContainer = $Panel/VBox/ScrollContainer/ItemList
@onready var _confirm_panel: PanelContainer = $ConfirmPanel
@onready var _confirm_label: Label = $ConfirmPanel/VBox/Label
@onready var _confirm_buy: Button = $ConfirmPanel/VBox/Buttons/BuyButton
@onready var _confirm_cancel: Button = $ConfirmPanel/VBox/Buttons/CancelButton

var _shop_items: Array[ItemData] = []
var _selected_item: ItemData = null
var _player_stats: SurvivorsPlayerStats


func _ready() -> void:
	is_modal = true
	_close_button.pressed.connect(func(): UIFlow.pop())
	_confirm_buy.pressed.connect(_on_buy_confirmed)
	_confirm_cancel.pressed.connect(_on_buy_cancelled)
	_confirm_panel.visible = false


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		_player_stats = data.get("player_stats", null)
		_shop_items = data.get("items", [])
		if data.has("inventory_data"):
			inventory_data = data.get("inventory_data")
	_rebuild_shop_list()
	_update_gold_display()


func _rebuild_shop_list() -> void:
	UIFlowUtils.clear_children(_item_list)

	for item in _shop_items:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		# Icon
		var icon := TextureRect.new()
		icon.texture = item.icon
		icon.custom_minimum_size = Vector2(32, 32)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)

		# Name + description
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 2)

		var name_label := Label.new()
		name_label.text = item.item_name
		name_label.add_theme_font_size_override("font_size", 14)
		name_label.add_theme_color_override("font_color", ItemData.get_rarity_color(item.rarity))
		info.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = item.description
		desc_label.add_theme_font_size_override("font_size", 11)
		desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size = Vector2(200, 0)
		info.add_child(desc_label)
		row.add_child(info)

		# Price + buy button
		var price_label := Label.new()
		price_label.text = "💰 %d" % item.sell_price
		price_label.add_theme_font_size_override("font_size", 14)
		row.add_child(price_label)

		var buy_btn := Button.new()
		buy_btn.text = "Buy"
		buy_btn.custom_minimum_size = Vector2(60, 32)
		var shop_item: ItemData = item
		buy_btn.pressed.connect(func(): _on_buy_pressed(shop_item))
		row.add_child(buy_btn)

		_item_list.add_child(row)


func _on_buy_pressed(item: ItemData) -> void:
	_selected_item = item
	_confirm_label.text = "Buy %s for 💰 %d?" % [item.item_name, item.sell_price]
	_confirm_panel.visible = true
	UIFlow.set_default_focus(_confirm_buy)


func _on_buy_confirmed() -> void:
	_confirm_panel.visible = false
	if _selected_item == null:
		return

	if _player_stats and _player_stats.gold >= _selected_item.sell_price:
		_player_stats.gold -= _selected_item.sell_price
		if inventory_data:
			var slot := inventory_data.add_item(_selected_item)
			if slot >= 0:
				UIFlowUI.Toast.show_toast("Bought %s!" % _selected_item.item_name, "success")
			else:
				UIFlowUI.Toast.show_toast("Inventory full!", "warning")
				_player_stats.gold += _selected_item.sell_price
		_update_gold_display()
	else:
		UIFlowUI.Toast.show_toast("Not enough gold!", "error")

	_selected_item = null


func _on_buy_cancelled() -> void:
	_confirm_panel.visible = false
	_selected_item = null


func _update_gold_display() -> void:
	if _player_stats:
		_gold_label.text = "💰 %d" % _player_stats.gold


func _on_back() -> void:
	if _confirm_panel.visible:
		_on_buy_cancelled()
	else:
		UIFlow.pop()
