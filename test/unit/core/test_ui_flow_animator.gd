## Tests for UIFlowAnimator — tween animation utility.
extends GdUnitTestSuite


## Test: animate returns a Tween
func test_animate_returns_tween() -> void:
	var node := Control.new()
	add_child(node)
	var tween: Tween = UIFlowAnimator.animate(
		node, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.1
	)
	assert_that(tween).is_not_null()
	assert_that(tween).is_instanceof(Tween)
	node.queue_free()


## Test: animate sets initial value
func test_animate_sets_initial() -> void:
	var node := Control.new()
	add_child(node)
	node.modulate.a = 1.0
	UIFlowAnimator.animate(node, UIFlowTweenProp.Prop.MODULATE_A, 0.5, 1.0, 0.1)
	assert_that(node.modulate.a).is_equal(0.5)
	node.queue_free()


## Test: animate_raw works with string path
func test_animate_raw() -> void:
	var node := Control.new()
	add_child(node)
	var tween: Tween = UIFlowAnimator.animate_raw(
		node, "modulate:a", 0.0, 1.0, 0.1
	)
	assert_that(tween).is_not_null()
	node.queue_free()


## Test: animate with null node returns null
func test_animate_null_node() -> void:
	var tween: Tween = UIFlowAnimator.animate(
		null, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.1
	)
	assert_that(tween).is_null()


## Test: sequencer creates UIFlowSequencer
func test_sequencer() -> void:
	var seq: UIFlowSequencer = UIFlowAnimator.sequencer()
	assert_that(seq).is_not_null()
	assert_that(seq).is_instanceof(UIFlowSequencer)
