@tool
## UIFlowTransitionAnimPlayer — plays a Godot Animation resource as a transition.
class_name UIFlowTransitionAnimPlayer extends UIFlowTransitionEffect

## The Animation resource to play. Assign this in the Inspector or via code.
@export var animation: Animation:
	get: return _animation
	set(value):
		_animation = value
		notify_property_list_changed()

var _animation: Animation = null


func _init(anim: Animation = null) -> void:
	_animation = anim


## Convenience factory that extracts an Animation from an AnimationPlayer.
static func from_animation_player(player: AnimationPlayer, anim_name: String) -> UIFlowTransitionAnimPlayer:
	if player == null:
		return null
	var lib := player.get_animation_library("")
	if lib == null:
		return null
	var anim: Animation = lib.get_animation(anim_name) as Animation
	if anim == null:
		return null
	return UIFlowTransitionAnimPlayer.new(anim)


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if _animation == null:
		_on_finished(callback)
		return
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return

	node.visible = true
	node.modulate.a = 1.0
	_play_on_node(node, _animation, false, callback)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if _animation == null:
		_on_finished(callback)
		return
	if not is_instance_valid(node) or not node.is_inside_tree():
		_on_finished(callback)
		return

	_play_on_node(node, _animation, true, callback)


func _play_on_node(node: Control, anim: Animation, backwards: bool, callback: Callable) -> void:
	var player := AnimationPlayer.new()
	player.name = "__uiflow_transition_player"
	node.add_child(player)

	var lib := AnimationLibrary.new()
	lib.add_animation("transition", anim)
	player.add_animation_library("", lib)

	player.animation_finished.connect(func(_anim_name: String):
		player.queue_free()
		_on_finished(callback)
	, CONNECT_ONE_SHOT)

	if backwards:
		player.play_backwards("transition")
	else:
		player.play("transition")
