## UIFlowAnimPresets — common UI animation presets.
##
## Provides ready-to-use animations for hover, press, shake, pulse, etc.
## All methods return the Tween for chaining or awaiting.
##
## Usage:
## [codeblock]
## # Button hover effect
## $Button.mouse_entered.connect(func():
##     UIFlow.anim_hover_enter($Button)
## )
## $Button.mouse_exited.connect(func():
##     UIFlow.anim_hover_exit($Button)
## )
##
## # Press bounce
## $Button.button_down.connect(func():
##     UIFlow.anim_press_down($Button)
## )
## $Button.button_up.connect(func():
##     UIFlow.anim_press_up($Button)
## )
## [/codeblock]
class_name UIFlowAnimPresets

# ── Hover Effects ────────────────────────────────────────────────────────────

## Scale up on hover.
static func hover_scale(node: Control, scale_to: Vector2 = Vector2(1.05, 1.05), duration: float = 0.15) -> Tween:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "scale", scale_to, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	return tween


## Brighten on hover.
static func hover_glow(node: Control, amount: float = 0.1, duration: float = 0.15) -> Tween:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate", Color(1 + amount, 1 + amount, 1 + amount), duration)
	return tween


## Reset hover effects.
static func hover_reset(node: Control, duration: float = 0.15) -> Tween:
	var tween: Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, duration)
	tween.tween_property(node, "modulate", Color.WHITE, duration)
	return tween


# ── Press Effects ────────────────────────────────────────────────────────────

## Scale down on press.
static func press_down(node: Control, scale_to: Vector2 = Vector2(0.95, 0.95), duration: float = 0.08) -> Tween:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "scale", scale_to, duration).set_ease(Tween.EASE_IN)
	return tween


## Release bounce back.
static func press_up(node: Control, duration: float = 0.15) -> Tween:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	return tween


# ── Shake Effects ────────────────────────────────────────────────────────────

## Shake node horizontally (error, damage).
static func shake(node: Control, intensity: float = 8.0, duration: float = 0.4, decay: bool = true) -> Tween:
	var original_x: float = node.position.x
	var tween: Tween = node.create_tween()
	var steps := 6
	for i in range(steps):
		var offset: float = intensity if not decay else intensity * (1.0 - float(i) / steps)
		if i % 2 == 0:
			tween.tween_property(node, "position:x", original_x + offset, duration / steps)
		else:
			tween.tween_property(node, "position:x", original_x - offset, duration / steps)
	tween.tween_property(node, "position:x", original_x, duration / steps)
	return tween


# ── Pulse Effects ────────────────────────────────────────────────────────────

## Pulse scale (attention, notification).
static func pulse(node: Control, scale_to: Vector2 = Vector2(1.15, 1.15), duration: float = 0.3) -> Tween:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "scale", scale_to, duration * 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, duration * 0.5).set_ease(Tween.EASE_IN)
	return tween


## Pulse alpha (blink, warning).
static func pulse_alpha(node: Control, min_alpha: float = 0.3, duration: float = 0.5) -> Tween:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate:a", min_alpha, duration * 0.5)
	tween.tween_property(node, "modulate:a", 1.0, duration * 0.5)
	return tween


# ── Slide Effects ────────────────────────────────────────────────────────────

## Slide in from left.
static func slide_in_left(node: Control, distance: float = 200.0, duration: float = 0.3) -> Tween:
	var target_x: float = node.position.x
	node.position.x -= distance
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "position:x", target_x, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	return tween


## Slide in from right.
static func slide_in_right(node: Control, distance: float = 200.0, duration: float = 0.3) -> Tween:
	var target_x: float = node.position.x
	node.position.x += distance
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "position:x", target_x, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	return tween


## Slide in from bottom.
static func slide_in_bottom(node: Control, distance: float = 100.0, duration: float = 0.3) -> Tween:
	var target_y: float = node.position.y
	node.position.y += distance
	node.modulate.a = 0.0
	var tween: Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "position:y", target_y, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "modulate:a", 1.0, duration * 0.6)
	return tween


# ── Fade Effects ─────────────────────────────────────────────────────────────

## Quick fade in.
static func fade_in(node: Control, duration: float = 0.2) -> Tween:
	node.modulate.a = 0.0
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)
	return tween


## Quick fade out.
static func fade_out(node: Control, duration: float = 0.2) -> Tween:
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	return tween


# ── Stagger Effects ──────────────────────────────────────────────────────────

## Stagger fade-in for multiple children.
static func stagger_fade_in(parent: Node, duration: float = 0.15, delay: float = 0.05) -> UIFlowSequencer:
	var seq := UIFlowSequencer.new()
	for i in range(parent.get_child_count()):
		var child: Control = parent.get_child(i) as Control
		if child:
			child.modulate.a = 0.0
			seq.add(child, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, duration).delay(delay * i)
	seq.play()
	return seq


## Stagger slide-in from bottom for multiple children.
static func stagger_slide_in(parent: Node, distance: float = 30.0, duration: float = 0.2, delay: float = 0.06) -> UIFlowSequencer:
	var seq := UIFlowSequencer.new()
	for i in range(parent.get_child_count()):
		var child: Control = parent.get_child(i) as Control
		if child:
			var target_y: float = child.position.y
			child.position.y = target_y + distance
			child.modulate.a = 0.0
			seq.add(child, UIFlowTweenProp.Prop.POSITION_Y, target_y + distance, target_y, duration).delay(delay * i)
	seq.play()
	return seq
