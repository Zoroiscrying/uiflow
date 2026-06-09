## UIFlowTransitionAnimPlayer — plays a Godot Animation resource as a transition.
class_name UIFlowTransitionAnimPlayer extends UIFlowTransitionEffect

var _animation: Animation


func _init(anim: Animation = null) -> void:
	_animation = anim


func play_enter(node: Control, callback: Callable = Callable()) -> void:
	if _animation == null:
		_on_finished(callback)
		return

	node.visible = true
	node.modulate.a = 1.0

	var player := AnimationPlayer.new()
	player.name = "__uiflow_transition_player"
	node.add_child(player)

	var lib := AnimationLibrary.new()
	lib.add_animation("transition", _animation)
	player.add_animation_library("", lib)

	player.play("transition")
	player.animation_finished.connect(func(_anim_name: String):
		player.queue_free()
		_on_finished(callback)
	, CONNECT_ONE_SHOT)


func play_exit(node: Control, callback: Callable = Callable()) -> void:
	if _animation == null:
		_on_finished(callback)
		return

	var player := AnimationPlayer.new()
	player.name = "__uiflow_transition_player"
	node.add_child(player)

	var lib := AnimationLibrary.new()
	lib.add_animation("transition", _animation)
	player.add_animation_library("", lib)

	player.play_backwards("transition")
	player.animation_finished.connect(func(_anim_name: String):
		player.queue_free()
		_on_finished(callback)
	, CONNECT_ONE_SHOT)
