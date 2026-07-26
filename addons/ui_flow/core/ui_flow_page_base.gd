## Base class for all UIFlow pages.
## Extend this class on any Control node that acts as a UI page.
##
## Lifecycle:
## 1. [code]_on_created(data)[/code] — Page instantiated, before added to tree
## 2. [code]_on_opened(data)[/code] — Page added to tree, before enter animation
## 3. [code]_on_after_opened()[/code] — Enter animation complete, focus applied
## 4. [code]_on_hidden()[/code] — Another page pushed on top
## 5. [code]_on_shown()[/code] — Page above popped, this page visible again
## 6. [code]_on_before_closed()[/code] — Exit animation about to start
## 7. [code]_on_closed()[/code] — Page removed from stack, after exit animation
## 8. [code]_on_destroyed()[/code] — Page about to be freed
##
## Configuration:
## - [code]is_modal[/code]: Intercept all input (modal dialog)
## - [code]allow_world_input[/code]: Keep gameplay input while this page is top (HUD)
## - [code]enter_effect[/code] / [code]exit_effect[/code]: Auto-play transitions
## - [code]default_focus_path[/code]: Auto-focus on open
## - UIInputActionNode children: Declare input actions
class_name UIFlowPage extends Control

# ── Page State ───────────────────────────────────────────────────────────────

enum State {
	IDLE,        ## Page instantiated but not yet in navigation stack
	CREATING,    ## _on_created is being called (before add_child)
	ENTERING,    ## Enter animation is playing
	OPENED,      ## Fully opened, interactive, on top of stack
	HIDDEN,      ## In stack but covered by another page
	EXITING,     ## Exit animation is playing
	CLOSED,      ## Removed from stack, awaiting cleanup
	DESTROYED,   ## Node has been freed
}

## Current state of this page in the navigation lifecycle.
var _state: State = State.IDLE

## Get the current lifecycle state.
func get_state() -> State:
	return _state

## True if the page is on top and interactive (ENTERING or OPENED).
func is_active() -> bool:
	return _state in [State.ENTERING, State.OPENED]

## True if the page is currently animating (CREATING, ENTERING, or EXITING).
func is_animating() -> bool:
	return _state in [State.CREATING, State.ENTERING, State.EXITING]


# ── Inspector Configuration ──────────────────────────────────────────────────

## If true, this page intercepts all input. Lower pages don't receive back/cancel.
## Modal covers also keep the page below visible (for dimmed HUDs) while blocking
## its GUI via [code]PROCESS_MODE_DISABLED[/code].
@export var is_modal: bool = false

## If true, world/gameplay input (player move, interact) stays active while this
## page is on top. Use for HUD pages. Modal pages always block world input.
@export var allow_world_input: bool = false

## Transition effect played when this page is pushed onto the stack.
@export var enter_effect: UIFlowTransitionEffect = null

## Transition effect played when this page is popped from the stack.
@export var exit_effect: UIFlowTransitionEffect = null

## If true and [member exit_effect] is empty, the page will automatically play
## [member enter_effect] in reverse when exiting (via its [method UIFlowTransitionEffect.play_exit]).
@export var exit_reverses_enter: bool = false

## NodePath to the control that should receive focus when the page opens.
@export var default_focus_path: NodePath = ""

# ── Internal ─────────────────────────────────────────────────────────────────

## Cached action nodes (auto-discovered from children).
var _action_nodes: Dictionary = {}
## Active data bindings, auto-cleaned when the page is closed.
var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []


func _ready() -> void:
	_discover_actions()


## Auto-discover UIInputActionNode descendants recursively.
func _discover_actions() -> void:
	_action_nodes.clear()
	for descendant in _find_descendants(self):
		if descendant is UIInputActionNode:
			_action_nodes[descendant.action_name] = descendant


func _find_descendants(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_find_descendants(child))
	return result


## Called by UIInputActionNode when it enters the tree.
func _register_action(action: UIInputActionNode) -> void:
	_action_nodes[action.action_name] = action


## Called by UIInputActionNode when it exits the tree.
func _unregister_action(action: UIInputActionNode) -> void:
	_action_nodes.erase(action.action_name)


# ── Auto-managed Data Bindings (unbound on page close) ───────────────────────

## Bind a Signal to a property on a node. Auto-cleaned when page closes.
func bind_signal(node: Node, prop_name: StringName, sig: Signal) -> UIFlowBindUtils.UIFlowBinding:
	var binding := UIFlowBindUtils.bind_signal(node, prop_name, sig)
	_bindings.append(binding)
	return binding


## Bind a Signal with a transform. Auto-cleaned when page closes.
func bind_signal_t(node: Node, prop_name: StringName, sig: Signal, transform: Callable) -> UIFlowBindUtils.UIFlowBinding:
	var binding := UIFlowBindUtils.bind_signal_t(node, prop_name, sig, transform)
	_bindings.append(binding)
	return binding


## Bind a Signal to node visibility. Auto-cleaned when page closes.
func bind_visible(node: Node, sig: Signal, predicate: Callable) -> UIFlowBindUtils.UIFlowBinding:
	var binding := UIFlowBindUtils.bind_visible(node, sig, predicate)
	_bindings.append(binding)
	return binding


## Bind a Signal with a format string. Auto-cleaned when page closes.
func bind_format(node: Node, prop_name: StringName, sig: Signal, format: String) -> UIFlowBindUtils.UIFlowBinding:
	var binding := UIFlowBindUtils.bind_format(node, prop_name, sig, format)
	_bindings.append(binding)
	return binding


## Two-way bind a Slider. Auto-cleaned when page closes.
func bind_slider(slider: Range, sig: Signal, setter: Callable) -> UIFlowBindUtils.UIFlowBinding:
	var binding := UIFlowBindUtils.bind_slider(slider, sig, setter)
	_bindings.append(binding)
	return binding


## Unbind all tracked bindings. Called automatically by Navigator on close.
func _unbind_all() -> void:
	for binding in _bindings:
		if binding != null:
			binding.unbind()
	_bindings.clear()
	# Auto-clear event bus subscriptions owned by this page
	var uiflow: Node = null
	if Engine.has_singleton("UIFlow"):
		uiflow = Engine.get_singleton("UIFlow")
	else:
		uiflow = get_node_or_null("/root/UIFlow")
	if uiflow:
		var event_bus = uiflow.get("EventBus")
		if event_bus:
			event_bus.clear_subscriber(self)


# ── Lifecycle (override these in subclasses) ─────────────────────────────────

## Helper: safely cast data to Dictionary (for backwards compatibility).
func _as_dict(data: Variant) -> Dictionary:
	if data is Dictionary:
		return data
	return {}

func _on_created(_data: Variant = null) -> void:
	_state = State.CREATING

func _on_opened(_data: Variant = null) -> void:
	_state = State.ENTERING

func _on_after_opened() -> void:
	_state = State.OPENED

func _on_hidden() -> void:
	_state = State.HIDDEN

func _on_shown() -> void:
	_state = State.OPENED

func _on_before_closed() -> void:
	# State is intentionally not changed here; the navigator sets EXITING
	# when the exit animation starts, and _on_before_closed is only a pre-exit hook.
	pass

func _on_closed() -> void:
	_state = State.CLOSED

func _on_destroyed() -> void:
	_state = State.DESTROYED


## Called when the page is returned to the object pool.
## Override to reset state (e.g. clear temporary data, stop animations).
func _on_pooled() -> void:
	_state = State.IDLE


## Called when the page is taken out of the object pool for reuse.
## Override to re-initialize state for the new context.
func _on_unpooled() -> void:
	_state = State.IDLE


# ── Framework hooks (called by Navigator, not by user) ──────────────────────

## Called by Navigator after _on_created. Applies default focus.
## Does nothing when [member UIFlowConfig.auto_focus_on_push] is false.
func _apply_default_focus() -> void:
	if default_focus_path.is_empty():
		return
	var focus_node: Control = get_node_or_null(default_focus_path) as Control
	if focus_node == null:
		return
	var uiflow: Node = null
	if Engine.has_singleton("UIFlow"):
		uiflow = Engine.get_singleton("UIFlow")
	else:
		uiflow = get_node_or_null("/root/UIFlow")
	if uiflow == null:
		return
	var cfg: UIFlowConfig = uiflow.get("Config")
	if cfg != null and not cfg.auto_focus_on_push:
		return
	if uiflow.has_method("set_default_focus"):
		uiflow.set_default_focus(focus_node)


## Called by Navigator after _on_opened. Plays enter animation.
## [param on_complete] is called when the animation finishes.
func _play_enter_animation(on_complete: Callable = Callable()) -> void:
	_state = State.ENTERING
	if enter_effect:
		enter_effect.play_enter(self, on_complete)
	else:
		if on_complete.is_valid():
			on_complete.call()


## Called by Navigator before removal. Plays exit animation.
## [param on_complete] is called when the animation finishes.
func _play_exit_animation(on_complete: Callable = Callable()) -> void:
	_state = State.EXITING
	if exit_effect:
		exit_effect.play_exit(self, on_complete)
	elif enter_effect and exit_reverses_enter:
		enter_effect.play_exit(self, on_complete)
	else:
		if on_complete.is_valid():
			on_complete.call()


# ── Input Action Access ──────────────────────────────────────────────────────

func get_action(action_name: StringName) -> UIInputActionNode:
	return _action_nodes.get(action_name, null)

func get_all_actions() -> Array:
	return _action_nodes.values()

func get_enabled_actions() -> Array:
	var result: Array = []
	for action in _action_nodes.values():
		if action.enabled:
			result.append(action)
	return result

func set_action_enabled(action_name: StringName, enabled: bool) -> void:
	var action := get_action(action_name)
	if action:
		action.enabled = enabled

func is_action_pressed(action_name: StringName) -> bool:
	var action := get_action(action_name)
	if action and action.enabled and action.action_type == UIInputActionNode.Type.BUTTON:
		return Input.is_action_pressed(action.godot_action)
	return false

func get_input_prompts() -> Array:
	var prompts: Array = []
	for action in _action_nodes.values():
		prompts.append({
			"label": action.label,
			"icon": action.icon,
			"enabled": action.enabled,
		})
	return prompts
