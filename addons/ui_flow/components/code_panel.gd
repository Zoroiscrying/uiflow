## UIFlowCodePanel — legacy sidebar (prefer [UIFlowCodeOverlay] for demos).
##
## Kept for compatibility. New demos should use [UIFlowCodeOverlay], which draws
## on a high CanvasLayer and supports F1 toggle from the main scene.
class_name UIFlowCodePanel extends Control

var _panel: PanelContainer
var _title_label: Label
var _snippets_container: VBoxContainer
var _toggle_button: Button
var _is_expanded: bool = true
var _expanded_width: float = 380.0
var _collapsed_width: float = 32.0


func _ready() -> void:
	var vp := get_viewport()
	if vp:
		size = vp.get_visible_rect().size
	get_viewport().size_changed.connect(_on_viewport_resized)

	_build_panel()


func _on_viewport_resized() -> void:
	var vp := get_viewport()
	if vp:
		size = vp.get_visible_rect().size
		_update_layout()


func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(size.x - _expanded_width, 0)
	_panel.size = Vector2(_expanded_width, size.y)
	add_child(_panel)

	var root_hbox := HBoxContainer.new()
	root_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_hbox.add_theme_constant_override("separation", 0)
	_panel.add_child(root_hbox)

	# Content area
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.name = "Content"
	root_hbox.add_child(content)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	content.add_child(header)

	_title_label = Label.new()
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 14)
	_title_label.text = "UIFlow API"
	header.add_child(_title_label)

	var collapse_btn := Button.new()
	collapse_btn.text = "»"
	collapse_btn.custom_minimum_size = Vector2(28, 28)
	collapse_btn.pressed.connect(func(): collapse())
	header.add_child(collapse_btn)

	var sep := HSeparator.new()
	content.add_child(sep)

	# Scrollable snippets
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	_snippets_container = VBoxContainer.new()
	_snippets_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_snippets_container.add_theme_constant_override("separation", 12)
	scroll.add_child(_snippets_container)

	# Toggle button (always visible, on the left edge of the panel)
	_toggle_button = Button.new()
	_toggle_button.text = "«"
	_toggle_button.custom_minimum_size = Vector2(_collapsed_width, 60)
	_toggle_button.position = Vector2(0, size.y / 2 - 30)
	_toggle_button.pressed.connect(func(): expand())
	_toggle_button.visible = false
	_toggle_button.z_index = 10
	add_child(_toggle_button)


func _update_layout() -> void:
	if _panel.visible:
		_panel.position = Vector2(size.x - _expanded_width, 0)
		_panel.size = Vector2(_expanded_width, size.y)
	_toggle_button.position = Vector2(size.x - _collapsed_width, size.y / 2 - 30)


## Collapse the panel to a narrow strip.
func collapse() -> void:
	_is_expanded = false
	_panel.visible = false
	_toggle_button.visible = true
	_toggle_button.position = Vector2(size.x - _collapsed_width, size.y / 2 - 30)


## Expand the panel to full width.
func expand() -> void:
	_is_expanded = true
	_panel.visible = true
	_toggle_button.visible = false
	_panel.position = Vector2(size.x - _expanded_width, 0)
	_panel.size = Vector2(_expanded_width, size.y)


## Toggle expanded/collapsed state.
func toggle() -> void:
	if _is_expanded:
		collapse()
	else:
		expand()


## Show API snippets for a page. Each snippet: { "title": String, "code": String }
func show_snippets(page_name: String, snippets: Array) -> void:
	# Clear old
	for child in _snippets_container.get_children():
		child.queue_free()

	_title_label.text = page_name

	for snippet in snippets:
		var block := VBoxContainer.new()
		block.add_theme_constant_override("separation", 4)

		var label := Label.new()
		label.text = snippet.get("title", "")
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
		block.add_child(label)

		var code_label := Label.new()
		code_label.text = snippet.get("code", "")
		code_label.add_theme_font_size_override("font_size", 11)
		code_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
		code_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		block.add_child(code_label)

		_snippets_container.add_child(block)

	expand()
