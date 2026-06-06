## UIFlow Editor Dock — sidebar panel showing project routes and configuration.
@tool
extends Control

var _tree: Tree
var _info_label: Label


func _ready() -> void:
	name = "UI Flow"

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	# Header
	var header := Label.new()
	header.text = "UI Flow"
	header.add_theme_font_size_override("font_size", 16)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	vbox.add_child(HSeparator.new())

	# Info label
	_info_label = Label.new()
	_info_label.text = "Routes are resolved by class_name convention.\nPlace scenes in UIScene/ directory."
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_info_label)

	vbox.add_child(HSeparator.new())

	# Scene list
	var scene_label := Label.new()
	scene_label.text = "UIScene/ Contents:"
	vbox.add_child(scene_label)

	_tree = Tree.new()
	_tree.custom_minimum_size = Vector2(0, 200)
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_tree)

	_refresh_tree()


func _refresh_tree() -> void:
	_tree.clear()
	var root := _tree.create_item()
	root.set_text(0, "UIScene")

	var dir := DirAccess.open("res://UIScene/")
	if dir == null:
		_info_label.text = "UIScene/ directory not found.\nCreate it to place your page scenes."
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var item := _tree.create_item(root)
			item.set_text(0, file_name)
			item.set_icon(0, get_theme_icon("PackedScene", "EditorIcons"))
		file_name = dir.get_next()
	dir.list_dir_end()

	if root.get_child_count() == 0:
		var item := _tree.create_item(root)
		item.set_text(0, "(empty)")
