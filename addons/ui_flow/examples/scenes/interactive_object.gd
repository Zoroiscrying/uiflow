## Interactive object — 3D object the player can interact with.
## When player enters range, shows prompts on MainHUD.
## When player presses E, opens the associated UI page.
extends Area3D

## Scene path of the UIFlowPage to open.
@export var page_scene_path: String = ""

## Display name for prompts.
@export var display_name: String = "Interact"

## Key / gamepad prompt — prefer semantic chips via get_interaction_prompts().
@export var key_prompt: String = ""

var _player_in_range: bool = false
var _main_hud: MainHUD = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_main_hud = UIFlow.get_page(MainHUD) as MainHUD
		if _main_hud:
			_main_hud.set_nearby_interactive(self)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if _main_hud:
			_main_hud.set_nearby_interactive(null)
		_main_hud = null


func get_interaction_prompts() -> Array:
	# Structured prompts so MainHUD can show device-aware Kenney icons.
	var label := display_name if not display_name.is_empty() else "Interact"
	return [{
		"semantic": &"interact",
		"label": label,
		"color": Color(0.25, 0.7, 0.35),
	}]


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or page_scene_path.is_empty():
		return
	var ui := get_node_or_null("/root/UIFlowUI")
	if ui != null and ui.has_method("has_blocking_dialog") and ui.has_blocking_dialog():
		return
	if event.is_action_pressed("interact"):
		# Don't open if any modal page is already open
		var top_page: Control = UIFlow.Router.current_page_instance()
		if top_page and top_page is UIFlowPage and (top_page as UIFlowPage).is_modal:
			return
		var scene: PackedScene = load(page_scene_path) as PackedScene
		if scene:
			var instance: Control = scene.instantiate()
			UIFlow.push_instance(instance)
			get_viewport().set_input_as_handled()
