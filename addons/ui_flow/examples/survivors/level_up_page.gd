## SurvivorsLevelUpPage — card selection on level up.
class_name SurvivorsLevelUpPage extends UIFlowPage

@onready var _card_container: HBoxContainer = $Dimmer/VBox/CardContainer

var _cards: Array = []
var _on_selected: Callable


func _ready() -> void:
	is_modal = true


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		_cards = data.get("cards", [])
		_on_selected = data.get("on_selected", Callable())
	_build_cards()
	# Stagger fade in
	UIFlow.anim_stagger_fade(_card_container)


func _build_cards() -> void:
	UIFlowUtils.clear_children(_card_container)
	for i in range(_cards.size()):
		var weapon: WeaponData = _cards[i]
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(180, 240)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 8)

		var icon := TextureRect.new()
		if weapon.icon:
			icon.texture = weapon.icon
		icon.custom_minimum_size = Vector2(64, 64)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(icon)

		var name_label := Label.new()
		name_label.text = weapon.weapon_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_color_override("font_color", WeaponData.get_rarity_color(weapon.rarity))
		vbox.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = weapon.description
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(desc_label)

		var stats_label := Label.new()
		stats_label.text = "DMG: %d | CD: %.1fs | RNG: %.0f" % [weapon.damage, weapon.cooldown, weapon.range]
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_label.add_theme_font_size_override("font_size", 12)
		vbox.add_child(stats_label)

		card.add_child(vbox)
		_card_container.add_child(card)

		# Tooltip
		UIFlowTooltip.attach(card, "%s\n%s\nDMG: %d | CD: %.1fs" % [weapon.weapon_name, weapon.description, weapon.damage, weapon.cooldown])

		# Click handler
		var idx := i
		card.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select_card(idx)
		)

		# Hover animation
		card.mouse_entered.connect(func(): UIFlow.anim_hover_enter(card))
		card.mouse_exited.connect(func(): UIFlow.anim_hover_exit(card))


func _select_card(index: int) -> void:
	if _on_selected.is_valid():
		_on_selected.call(_cards[index])
	UIFlow.pop()
