## Global code-snippet overlay (CanvasLayer) for demos and tooling.
##
## Lives above [code]UIFlowPageLayer[/code]. Always shows a corner chip
## ("F1 · Code"); press F1 or click the chip to toggle the panel.
## Overlay controls use [code]FOCUS_NONE[/code] so they never steal gamepad focus.
class_name UIFlowCodeOverlay extends CanvasLayer

signal toggled(expanded: bool)

var _root: Control
var _panel: PanelContainer
var _tab: Button
var _title_label: Label
var _snippets_container: VBoxContainer
var _hint_label: Label
var _is_expanded: bool = false
var _expanded_width: float = 400.0


func _ready() -> void:
	layer = UIFlowOverlayHost.OVERLAY_LAYER
	_build()
	collapse()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		toggle()
		get_viewport().set_input_as_handled()


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.focus_mode = Control.FOCUS_NONE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.08, 0.11, 0.94)
	style.set_corner_radius_all(0)
	style.set_content_margin_all(12)
	style.border_color = Color(0.25, 0.35, 0.5, 0.8)
	style.border_width_left = 2
	_panel.add_theme_stylebox_override("panel", style)
	_root.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	_title_label = Label.new()
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 15)
	_title_label.text = "UIFlow API"
	_title_label.focus_mode = Control.FOCUS_NONE
	header.add_child(_title_label)

	var close_btn := Button.new()
	close_btn.text = "Hide"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(collapse)
	header.add_child(close_btn)

	_hint_label = Label.new()
	_hint_label.text = "F1 — toggle · click Hide or F1 again to close"
	_hint_label.add_theme_font_size_override("font_size", 11)
	_hint_label.modulate = Color(1, 1, 1, 0.45)
	_hint_label.focus_mode = Control.FOCUS_NONE
	vbox.add_child(_hint_label)

	vbox.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.focus_mode = Control.FOCUS_NONE
	vbox.add_child(scroll)

	_snippets_container = VBoxContainer.new()
	_snippets_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_snippets_container.add_theme_constant_override("separation", 14)
	scroll.add_child(_snippets_container)

	# Always-visible F1 chip (does not take gamepad focus).
	_tab = Button.new()
	_tab.text = "F1 · Code"
	_tab.focus_mode = Control.FOCUS_NONE
	_tab.custom_minimum_size = Vector2(88, 36)
	_tab.pressed.connect(toggle)
	var tab_style := StyleBoxFlat.new()
	tab_style.bg_color = Color(0.12, 0.18, 0.28, 0.92)
	tab_style.set_corner_radius_all(6)
	tab_style.set_content_margin_all(8)
	tab_style.border_color = Color(0.4, 0.6, 0.9, 0.7)
	tab_style.set_border_width_all(1)
	_tab.add_theme_stylebox_override("normal", tab_style)
	_tab.add_theme_stylebox_override("hover", tab_style)
	_tab.add_theme_stylebox_override("pressed", tab_style)
	_root.add_child(_tab)

	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var size := vp.get_visible_rect().size
	if _panel != null:
		_panel.position = Vector2(size.x - _expanded_width, 0)
		_panel.size = Vector2(_expanded_width, size.y)
	if _tab != null:
		# Pin to top-right; nudge left when panel is open so it stays visible.
		var tab_x: float = size.x - _tab.size.x - 12.0
		if _is_expanded:
			tab_x = size.x - _expanded_width - _tab.size.x - 8.0
		_tab.position = Vector2(maxi(tab_x, 8.0), 12.0)
		_tab.visible = true


func expand() -> void:
	_is_expanded = true
	if _panel:
		_panel.visible = true
	if _tab:
		_tab.text = "F1 · Hide"
	_layout()
	toggled.emit(true)


func collapse() -> void:
	_is_expanded = false
	if _panel:
		_panel.visible = false
	if _tab:
		_tab.text = "F1 · Code"
	_layout()
	toggled.emit(false)


func toggle() -> void:
	if _is_expanded:
		collapse()
	else:
		expand()


func is_expanded() -> bool:
	return _is_expanded


## Each snippet: { "title": String, "code": String }
func show_snippets(page_name: String, snippets: Array) -> void:
	if _snippets_container == null:
		call_deferred("show_snippets", page_name, snippets)
		return
	for child in _snippets_container.get_children():
		child.queue_free()

	_title_label.text = page_name if not page_name.is_empty() else "UIFlow API"

	if snippets.is_empty():
		var empty := Label.new()
		empty.text = "No snippets for this page.\nPress F1 to hide."
		empty.modulate = Color(1, 1, 1, 0.5)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.focus_mode = Control.FOCUS_NONE
		_snippets_container.add_child(empty)
		# Keep current visibility; do not force-open on empty pages.
		return

	for snippet in snippets:
		var block := VBoxContainer.new()
		block.add_theme_constant_override("separation", 4)

		var label := Label.new()
		label.text = str(snippet.get("title", ""))
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0))
		label.focus_mode = Control.FOCUS_NONE
		block.add_child(label)

		var code_panel := PanelContainer.new()
		code_panel.focus_mode = Control.FOCUS_NONE
		var code_style := StyleBoxFlat.new()
		code_style.bg_color = Color(0.04, 0.05, 0.07, 1)
		code_style.set_corner_radius_all(4)
		code_style.set_content_margin_all(8)
		code_panel.add_theme_stylebox_override("panel", code_style)
		block.add_child(code_panel)

		var code_label := Label.new()
		code_label.text = str(snippet.get("code", ""))
		code_label.add_theme_font_size_override("font_size", 11)
		code_label.add_theme_color_override("font_color", Color(0.88, 0.9, 0.85))
		code_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		code_label.focus_mode = Control.FOCUS_NONE
		code_panel.add_child(code_label)

		_snippets_container.add_child(block)
