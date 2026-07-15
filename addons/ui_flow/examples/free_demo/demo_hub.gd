## UIFlow Free Demo Hub — showcases core UIFlow features.
class_name UIFlowDemoHub extends UIFlowPage

const DemoNavigation = preload("res://addons/ui_flow/examples/free_demo/demo_navigation.gd")
const DemoDataBinding = preload("res://addons/ui_flow/examples/free_demo/demo_data_binding.gd")
const DemoTransitions = preload("res://addons/ui_flow/examples/free_demo/demo_transitions.gd")
const DemoComponents = preload("res://addons/ui_flow/examples/free_demo/demo_components.gd")
const DemoTheme = preload("res://addons/ui_flow/examples/free_demo/demo_theme.gd")
const DemoTimelineAsync = preload("res://addons/ui_flow/examples/free_demo/demo_timeline_async.gd")

@onready var _buttons: VBoxContainer = $Margin/Scroll/VBox/Buttons


func _ready() -> void:
	_buttons.get_child(0).pressed.connect(func():
		UIFlow.push(DemoNavigation))
	_buttons.get_child(1).pressed.connect(func():
		UIFlow.push(DemoDataBinding))
	_buttons.get_child(2).pressed.connect(func():
		UIFlow.push(DemoTransitions))
	_buttons.get_child(3).pressed.connect(func():
		UIFlow.push(DemoComponents))
	_buttons.get_child(4).pressed.connect(func():
		UIFlow.push(DemoTheme))
	_buttons.get_child(5).pressed.connect(func():
		UIFlow.push(DemoTimelineAsync))
	_buttons.get_child(6).pressed.connect(func():
		var tree := get_tree()
		UIFlow.pop()
		tree.change_scene_to_file("res://addons/ui_flow/examples/scenes/gamepad_demo.tscn")
	)
	_buttons.get_child(7).pressed.connect(func():
		var tree := get_tree()
		UIFlow.pop()
		tree.change_scene_to_file("res://addons/ui_flow/examples/scenes/game_world.tscn")
	)
	_buttons.get_child(8).pressed.connect(func():
		var tree := get_tree()
		UIFlow.pop()
		tree.change_scene_to_file("res://addons/ui_flow_pro/examples/survivors/arpg_main.tscn")
	)


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus(_buttons.get_child(0) as Button)


func _on_shown() -> void:
	UIFlow.set_default_focus(_buttons.get_child(0) as Button)


func _on_back() -> void:
	pass  # Root page — no back action
