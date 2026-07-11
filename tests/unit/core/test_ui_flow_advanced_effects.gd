extends GdUnitTestSuite


var _nodes: Array[Control] = []


func before_test() -> void:
	_nodes.clear()


func after_test() -> void:
	for node: Control in _nodes:
		if is_instance_valid(node):
			node.queue_free()
	_nodes.clear()


## Test: flip effect enter animation sets the node scale to visible_scale.
func test_flip_effect_enter_sets_visible_scale() -> void:
	var node := Control.new()
	node.size = Vector2(200.0, 200.0)
	add_child(node)
	_nodes.append(node)

	var finished := [false]
	var effect := UIFlowFlipEffect.new()
	effect.duration = 0.05
	effect.flip_axis = UIFlowFlipEffect.FlipAxis.HORIZONTAL
	effect.visible_scale = Vector2.ONE
	effect.hidden_scale = Vector2(0.0, 1.0)

	effect.play_enter(node, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_vector(node.scale).is_equal(Vector2.ONE)


## Test: flip effect exit animation sets the node scale to hidden_scale.
func test_flip_effect_exit_sets_hidden_scale() -> void:
	var node := Control.new()
	node.size = Vector2(200.0, 200.0)
	node.scale = Vector2.ONE
	add_child(node)
	_nodes.append(node)

	var finished := [false]
	var effect := UIFlowFlipEffect.new()
	effect.duration = 0.05
	effect.flip_axis = UIFlowFlipEffect.FlipAxis.HORIZONTAL
	effect.visible_scale = Vector2.ONE
	effect.hidden_scale = Vector2(0.0, 1.0)

	effect.play_exit(node, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_vector(node.scale).is_equal_approx(Vector2(0.0, 1.0), Vector2(0.001, 0.001))


## Test: vertical flip axis uses a vertical hidden_scale.
func test_flip_effect_vertical_axis() -> void:
	var node := Control.new()
	node.size = Vector2(200.0, 200.0)
	add_child(node)
	_nodes.append(node)

	var finished := [false]
	var effect := UIFlowFlipEffect.new()
	effect.duration = 0.05
	effect.flip_axis = UIFlowFlipEffect.FlipAxis.VERTICAL
	effect.visible_scale = Vector2.ONE

	effect.play_enter(node, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_vector(node.scale).is_equal(Vector2.ONE)

	finished[0] = false
	effect.play_exit(node, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_vector(node.scale).is_equal_approx(Vector2(1.0, 0.0), Vector2(0.001, 0.001))


## Test: playing enter on a null node invokes the callback immediately.
func test_flip_effect_callback_on_null_node() -> void:
	var effect := UIFlowFlipEffect.new()
	var finished := [false]

	effect.play_enter(null, func(): finished[0] = true)

	assert_bool(finished[0]).is_true()


## Test: from_current preserves the node's existing scale as the animation start.
func test_flip_effect_from_current_preserves_scale() -> void:
	var node := Control.new()
	node.size = Vector2(200.0, 200.0)
	node.scale = Vector2(0.5, 1.0)
	add_child(node)
	_nodes.append(node)

	var finished := [false]
	var effect := UIFlowFlipEffect.new()
	effect.duration = 0.05
	effect.from_current = true
	effect.flip_axis = UIFlowFlipEffect.FlipAxis.HORIZONTAL
	# Match the target to the current scale so the value remains unchanged.
	effect.visible_scale = Vector2(0.5, 1.0)

	effect.play_enter(node, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_vector(node.scale).is_equal(Vector2(0.5, 1.0))


## Test: elastic scale effect maps each preset to the correct Tween transition type.
func test_elastic_scale_effect_maps_preset_to_trans_type() -> void:
	var effect := UIFlowElasticScaleEffect.new()

	effect.preset = UIFlowElasticScaleEffect.Preset.BOUNCE
	assert_int(effect.trans_type).is_equal(Tween.TRANS_BOUNCE)

	effect.preset = UIFlowElasticScaleEffect.Preset.ELASTIC
	assert_int(effect.trans_type).is_equal(Tween.TRANS_ELASTIC)

	effect.preset = UIFlowElasticScaleEffect.Preset.BACK
	assert_int(effect.trans_type).is_equal(Tween.TRANS_BACK)


## Test: elastic scale effect enter animation sets the node scale to visible_scale.
func test_elastic_scale_effect_enter_sets_visible_scale() -> void:
	var node := Control.new()
	node.size = Vector2(200.0, 200.0)
	add_child(node)
	_nodes.append(node)

	var finished := [false]
	var effect := UIFlowElasticScaleEffect.new()
	effect.duration = 0.05
	effect.hidden_scale = Vector2.ZERO
	effect.visible_scale = Vector2.ONE

	effect.play_enter(node, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_vector(node.scale).is_equal(Vector2.ONE)



## Test: animation player effect plays the assigned Animation resource on enter.
func test_anim_player_effect_plays_enter_animation() -> void:
	var node := Control.new()
	node.modulate = Color(1.0, 1.0, 1.0, 0.0)
	add_child(node)
	_nodes.append(node)

	var anim := Animation.new()
	var track := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track, "modulate:a")
	anim.track_insert_key(track, 0.0, 0.0)
	anim.track_insert_key(track, 0.05, 1.0)
	anim.length = 0.05

	var effect := UIFlowTransitionAnimPlayer.new(anim)
	var finished := [false]
	effect.play_enter(node, func(): finished[0] = true)
	await get_tree().create_timer(0.2).timeout

	assert_bool(finished[0]).is_true()
	assert_float(node.modulate.a).is_equal_approx(1.0, 0.01)


## Test: from_animation_player factory extracts the Animation by name.
func test_anim_player_effect_from_animation_player() -> void:
	var root := Node2D.new()
	var player := AnimationPlayer.new()
	root.add_child(player)
	add_child(root)
	_nodes.append(root)

	var anim := Animation.new()
	anim.length = 0.1
	var lib := AnimationLibrary.new()
	lib.add_animation("my_anim", anim)
	player.add_animation_library("", lib)

	var effect := UIFlowTransitionAnimPlayer.from_animation_player(player, "my_anim")
	assert_that(effect).is_not_null()
	assert_that(effect.animation).is_same(anim)
