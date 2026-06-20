## UIFlow Editor Dock — sidebar panel showing page navigation, transitions, and configuration.
@tool
extends Control

var _tree: Tree
var _info_label: Label
var _preview_container: Control
var _scene_dirs: Array[String] = []


func _ready() -> void:
	name = "UI Flow"

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	vbox.add_child(header)

	var title := Label.new()
	title.text = "UI Flow"
	title.add_theme_font_size_override("font_size", 16)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var refresh_btn := Button.new()
	refresh_btn.text = "Refresh"
	refresh_btn.pressed.connect(_refresh_tree)
	header.add_child(refresh_btn)

	var settings_btn := Button.new()
	settings_btn.text = "Settings"
	settings_btn.pressed.connect(_open_settings)
	header.add_child(settings_btn)

	vbox.add_child(HSeparator.new())

	# Info label
	_info_label = Label.new()
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_info_label)

	vbox.add_child(HSeparator.new())

	# Scene list
	var scene_label := Label.new()
	scene_label.text = "Page Scenes"
	scene_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(scene_label)

	_tree = Tree.new()
	_tree.custom_minimum_size = Vector2(0, 200)
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.column_titles_visible = true
	_tree.set_columns(2)
	_tree.set_column_title(0, "Page")
	_tree.set_column_title(1, "Info")
	_tree.set_column_expand(0, true)
	_tree.set_column_expand(1, false)
	_tree.set_column_custom_minimum_width(1, 80)
	vbox.add_child(_tree)

	_tree.item_activated.connect(_on_item_activated)

	vbox.add_child(HSeparator.new())

	# Transition preview section
	var preview_label := Label.new()
	preview_label.text = "Transition Preview"
	preview_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(preview_label)

	var preview_hbox := HBoxContainer.new()
	preview_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(preview_hbox)

	var preview_btn_fade := Button.new()
	preview_btn_fade.text = "Fade"
	preview_btn_fade.pressed.connect(func(): _preview_transition("fade"))
	preview_hbox.add_child(preview_btn_fade)

	var preview_btn_slide := Button.new()
	preview_btn_slide.text = "Slide"
	preview_btn_slide.pressed.connect(func(): _preview_transition("slide"))
	preview_hbox.add_child(preview_btn_slide)

	var preview_btn_scale := Button.new()
	preview_btn_scale.text = "Scale"
	preview_btn_scale.pressed.connect(func(): _preview_transition("scale"))
	preview_hbox.add_child(preview_btn_scale)

	# Preview area
	_preview_container = Control.new()
	_preview_container.custom_minimum_size = Vector2(0, 100)
	vbox.add_child(_preview_container)

	# Load scene dirs from settings
	_scene_dirs.clear()
	_scene_dirs.append("res://UIScene/")
	if ProjectSettings.has_setting("ui_flow/scene_directory"):
		var custom_dir: String = ProjectSettings.get_setting("ui_flow/scene_directory")
		if not custom_dir.is_empty() and not _scene_dirs.has(custom_dir):
			_scene_dirs.append(custom_dir)
	_scene_dirs.append("res://addons/ui_flow/examples/scenes/UIScene/")
	_scene_dirs.append("res://addons/ui_flow_pro/examples/scenes/")

	_info_label.text = "Scenes found in:\n%s\nClick to open scene or script." % "\n".join(_scene_dirs)

	_refresh_tree()


func _refresh_tree() -> void:
	_tree.clear()

	for scene_dir in _scene_dirs:
		var dir := DirAccess.open(scene_dir)
		if dir == null:
			continue

		var dir_name := scene_dir.rstrip("/").get_file()
		var root := _tree.create_item()
		root.set_text(0, dir_name)
		root.set_text(1, scene_dir)

		var scenes: Array[String] = []
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				scenes.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

		scenes.sort()

		for scene_name in scenes:
			var item := _tree.create_item(root)
			item.set_text(0, scene_name.replace(".tscn", ""))
			item.set_icon(0, get_theme_icon("PackedScene", "EditorIcons"))
			item.set_metadata(0, scene_dir + scene_name)
			var info := _get_scene_info(scene_dir + scene_name)
			item.set_text(1, info)

		if root.get_child_count() == 0:
			var item := _tree.create_item(root)
			item.set_text(0, "(empty)")
			item.set_text(1, "")


func _get_scene_info(scene_path: String) -> String:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	if file == null:
		return ""

	var content := file.get_as_text()
	var info_parts: Array[String] = []

	# Check for is_modal
	if content.contains("is_modal = true"):
		info_parts.append("modal")

	# Check for script reference
	if content.contains("script = ExtResource"):
		info_parts.append("scripted")

	# Check for enter/exit transition
	if content.contains("enter_effect"):
		info_parts.append("transition")

	return ", ".join(info_parts) if info_parts.is_empty() == false else ""


func _on_item_activated() -> void:
	var item := _tree.get_selected()
	if item == null:
		return

	var meta = item.get_metadata(0)
	if meta == null or not meta is String or meta.is_empty():
		return

	# Open scene in editor
	EditorInterface.open_scene_from_path(meta)


func _open_settings() -> void:
	var base := EditorInterface.get_base_control()

	var dialog := ConfirmationDialog.new()
	dialog.title = "UIFlow Settings"
	dialog.min_size = Vector2(500, 180)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)

	var label := Label.new()
	label.text = "Scene Directory:"
	vbox.add_child(label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var line_edit := LineEdit.new()
	line_edit.text = _get_scene_dir_setting()
	line_edit.placeholder_text = "res://UIScene/"
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(line_edit)

	var browse_btn := Button.new()
	browse_btn.text = "Browse..."
	browse_btn.custom_minimum_size = Vector2(80, 0)
	browse_btn.pressed.connect(func():
		var file_dialog := EditorFileDialog.new()
		file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
		file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
		file_dialog.title = "Select Scene Directory"
		file_dialog.current_dir = line_edit.text if DirAccess.dir_exists_absolute(line_edit.text) else "res://"
		file_dialog.dir_selected.connect(func(path: String):
			line_edit.text = path + "/"
		)
		base.add_child(file_dialog)
		file_dialog.popup_centered(Vector2(700, 500))
	)
	hbox.add_child(browse_btn)

	vbox.add_child(hbox)

	var hint := Label.new()
	hint.text = "Pages are resolved from this directory. Restart editor after changing."
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(hint)

	dialog.add_child(vbox)
	dialog.confirmed.connect(func():
		var new_dir: String = line_edit.text.strip_edges()
		if not new_dir.is_empty():
			if not new_dir.ends_with("/"):
				new_dir += "/"
			ProjectSettings.set_setting("ui_flow/scene_directory", new_dir)
			ProjectSettings.save()
			_refresh_tree()
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())
	base.add_child(dialog)
	dialog.popup_centered()


func _get_scene_dir_setting() -> String:
	if ProjectSettings.has_setting("ui_flow/scene_directory"):
		return ProjectSettings.get_setting("ui_flow/scene_directory")
	return "res://UIScene/"


func _preview_transition(type: String) -> void:
	# Clear previous preview
	for child in _preview_container.get_children():
		child.queue_free()

	# Create preview panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_preview_container.add_child(panel)

	var label := Label.new()
	label.text = "Preview: %s" % type
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(label)

	# Apply transition effect
	match type:
		"fade":
			panel.modulate.a = 0.0
			var tween := create_tween()
			tween.tween_property(panel, "modulate:a", 1.0, 0.3)
			tween.tween_property(panel, "modulate:a", 0.0, 0.3).set_delay(0.5)
			tween.finished.connect(func(): panel.queue_free())
		"slide":
			panel.position.x = -200
			var tween := create_tween()
			tween.tween_property(panel, "position:x", 0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.tween_property(panel, "position:x", -200, 0.3).set_delay(0.5)
			tween.finished.connect(func(): panel.queue_free())
		"scale":
			panel.scale = Vector2.ZERO
			var tween := create_tween()
			tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.tween_property(panel, "scale", Vector2.ZERO, 0.3).set_delay(0.5)
			tween.finished.connect(func(): panel.queue_free())
