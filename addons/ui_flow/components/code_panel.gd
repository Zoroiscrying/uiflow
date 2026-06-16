## UIFlowCodePanel — collapsible sidebar showing UIFlow API snippets.
class_name UIFlowCodePanel extends Control

var _panel: PanelContainer
var _title_label: Label
var _snippets_container: VBoxContainer
var _tab_button: Button
var _is_open: bool = false
var _panel_width: float = 380.0


func _ready() -> void:
	var vp := get_viewport()
	if vp:
		size = vp.get_visible_rect().size
	get_viewport().size_changed.connect(func():
		var v := get_viewport()
		if v:
			size = v.get_visible_rect().size
			_tab_button.position = Vector2(size.x - 40, size.y / 2 - 40)
			_panel.position = Vector2(size.x - _panel_width, 0)
			_panel.size = Vector2(_panel_width, size.y)
	)

	_build_tab_button()
	_build_panel()


func _build_tab_button() -> void:
	_tab_button = Button.new()
	_tab_button.text = "< >"
	_tab_button.custom_minimum_size = Vector2(32, 80)
	_tab_button.position = Vector2(size.x - 40, size.y / 2 - 40)
	_tab_button.pressed.connect(func(): toggle())
	add_child(_tab_button)


func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.position = Vector2(size.x - _panel_width, 0)
	_panel.size = Vector2(_panel_width, size.y)
	add_child(_panel)

	var root_vbox := VBoxContainer.new()
	root_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel.add_child(root_vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	root_vbox.add_child(header)

	_title_label = Label.new()
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 14)
	_title_label.text = "UIFlow API"
	header.add_child(_title_label)

	var close_btn := Button.new()
	close_btn.text = "×"
	close_btn.custom_minimum_size = Vector2(28, 28)
	close_btn.pressed.connect(func(): toggle())
	header.add_child(close_btn)

	var sep := HSeparator.new()
	root_vbox.add_child(sep)

	# Scrollable snippets
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(scroll)

	_snippets_container = VBoxContainer.new()
	_snippets_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_snippets_container.add_theme_constant_override("separation", 12)
	scroll.add_child(_snippets_container)


## Toggle the code panel visibility.
func toggle() -> void:
	_is_open = not _is_open
	_panel.visible = _is_open
	_tab_button.visible = not _is_open


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

	_panel.visible = true
	_is_open = true
	_tab_button.visible = false
