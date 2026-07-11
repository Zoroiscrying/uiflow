class_name SharedElementHubPage extends UIFlowPage

const SharedElementDetailPage := preload("res://addons/ui_flow/examples/shared_element/shared_element_detail_page.gd")
const ShopCurve := preload("res://addons/ui_flow/examples/shared_element/shared_element_shop_curve.tres")

@onready var _settings_button: Button = $SettingsButton
@onready var _shop_button: Button = $ShopButton
@onready var _bag_button: Button = $BagButton


func _ready() -> void:
	_settings_button.pressed.connect(_open_settings)
	_shop_button.pressed.connect(_open_shop)
	_bag_button.pressed.connect(_open_bag)


func _open_settings() -> void:
	var effect := UIFlowSharedElementTransition.create(&"SettingsIcon", 0.5)
	UIFlow.push(SharedElementDetailPage, { "icon": &"SettingsIcon", "title": "Settings", "effect": effect })


func _open_shop() -> void:
	var effect := UIFlowSharedElementTransition.create(&"ShopIcon", 0.7)
	effect.path_curve = ShopCurve
	UIFlow.push(SharedElementDetailPage, { "icon": &"ShopIcon", "title": "Shop", "effect": effect })


func _open_bag() -> void:
	var effect := UIFlowSharedElementTransition.create(&"BagIcon", 0.6)
	effect.morph_rotation = true
	effect.morph_scale = true
	UIFlow.push(SharedElementDetailPage, { "icon": &"BagIcon", "title": "Bag", "effect": effect })


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_settings_button)
