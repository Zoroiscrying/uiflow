## Interactive object — 3D object the player can interact with.
## When player enters range, shows prompts on MainHUD.
## When player presses E, opens the associated UI page.
extends Area3D

## Scene path of the UIFlowPage to open.
@export var page_scene_path: String = ""

## Display name for prompts.
@export var display_name: String = "Interact"

## Key prompt text.
@export var key_prompt: String = "[E] Open"

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
	return ["%s %s" % [key_prompt, display_name]]


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or page_scene_path.is_empty():
		return
	if event.is_action_pressed("interact"):
		var scene: PackedScene = load(page_scene_path) as PackedScene
		if scene:
			var instance: Control = scene.instantiate()
			UIFlow.push_instance(instance)
		get_viewport().set_input_as_handled()
