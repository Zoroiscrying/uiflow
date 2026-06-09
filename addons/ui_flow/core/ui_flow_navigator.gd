## Navigation stack manager for UIFlow pages.
## Manages push/pop/replace operations and page lifecycle.
## Pages handle their own animations via _on_opened/_on_closed callbacks.
class_name UIFlowNavigator extends Node

signal page_pushed(page_class: GDScript, data: Dictionary)
signal page_popped(page_class: GDScript)
signal page_opened(page_class: GDScript)   # Emitted when _on_opened completes
signal page_closed(page_class: GDScript)   # Emitted when _on_closed completes

var _stack: Array[Dictionary] = [] # { "class": GDScript, "instance": Control, "scene": PackedScene }
var _scene_resolver: UIFlowSceneResolver
var _container: Control
const _GuardClass = preload("res://addons/ui_flow/core/ui_flow_guard.gd")
var _guard  # UIFlowGuard


func setup(p_container: Control, p_resolver: UIFlowSceneResolver) -> void:
	_container = p_container
	_scene_resolver = p_resolver
	_guard = _GuardClass.new()


## Get the guard system for adding navigation guards.
func get_guard():
	return _guard


## Push a new page onto the stack.
## Returns the page instance. Returns null if blocked by a guard.
func push(page_class: GDScript, data: Dictionary = {}, page_theme: UIFlowTheme = null) -> Control:
	# No-op if page is already in stack — return existing instance
	var existing := get_page(page_class)
	if existing:
		return existing

	# Check guards
	var from_class: GDScript = current_page_class()
	if _guard and not _guard.can_navigate(from_class, page_class, data):
		return null

	var scene: PackedScene = _scene_resolver.resolve(page_class)
	if scene == null:
		return null

	# Notify current top page it's being hidden
	if _stack.size() > 0:
		var current: Dictionary = _stack.back()
		var current_page: UIFlowPage = current["instance"] as UIFlowPage
		if current_page and current_page.has_method("_on_hidden"):
			current_page._on_hidden()

	# Instantiate and add to tree
	var instance: Control = scene.instantiate()
	# Check if the enter effect wants the node to start hidden
	var starts_hidden := false
	if instance is UIFlowPage and instance.enter_transition:
		var effect = instance.enter_transition.get_enter_effect()
		if effect and effect.starts_hidden:
			starts_hidden = true
	instance.visible = not starts_hidden
	instance.modulate.a = 0.0 if starts_hidden else 1.0
	_container.add_child(instance)

	# Apply theme
	if page_theme:
		instance.theme = page_theme.build_godot_theme()

	_stack.push_back({
		"class": page_class,
		"instance": instance,
		"scene": scene,
	})

	# Lifecycle
	var page: UIFlowPage = instance as UIFlowPage
	if page and page.has_method("_on_created"):
		page._on_created(data)

	if page and page.has_method("_on_opened"):
		page._on_opened(data)

	# Play enter animation AFTER _on_opened (so _ready + _on_opened can set it up)
	if page:
		page._play_enter_animation()

	# Auto-focus (from @export default_focus_path)
	if page:
		page._apply_default_focus()

	page_pushed.emit(page_class, data)
	page_opened.emit(page_class)
	return instance


## Push a pre-instantiated page instance.
func push_instance(instance: Control, data: Dictionary = {}) -> Control:
	if _stack.size() > 0:
		var current: Dictionary = _stack.back()
		var current_page: UIFlowPage = current["instance"] as UIFlowPage
		if current_page and current_page.has_method("_on_hidden"):
			current_page._on_hidden()

	instance.visible = true
	instance.modulate.a = 1.0
	_container.add_child(instance)

	_stack.push_back({
		"class": instance.get_script(),
		"instance": instance,
		"scene": null,
	})

	var page: UIFlowPage = instance as UIFlowPage
	if page and page.has_method("_on_created"):
		page._on_created(data)
	if page and page.has_method("_on_opened"):
		page._on_opened(data)

	# Play enter animation
	if page:
		page._play_enter_animation()

	page_pushed.emit(instance.get_script(), data)
	return instance


## Pop the top page off the stack.
func pop() -> void:
	if _stack.is_empty():
		push_warning("UIFlow: Navigation stack is empty, cannot pop.")
		return

	var top: Dictionary = _stack.pop_back()
	var top_instance: Control = top["instance"]
	var top_class: GDScript = top["class"]

	# Play exit animation, then clean up
	var page: UIFlowPage = top_instance as UIFlowPage
	if page:
		page._play_exit_animation(func():
			_cleanup_after_pop(top_instance, top_class)
		)
	else:
		_cleanup_after_pop(top_instance, top_class)


func _cleanup_after_pop(top_instance: Control, top_class: GDScript) -> void:
	# Lifecycle
	var page: UIFlowPage = top_instance as UIFlowPage
	if page and page.has_method("_on_closed"):
		page._on_closed()
	if page and page.has_method("_on_destroyed"):
		page._on_destroyed()

	# Remove from tree
	if is_instance_valid(top_instance) and top_instance.is_inside_tree():
		_container.remove_child(top_instance)
		top_instance.queue_free()

	# Notify page below
	if _stack.size() > 0:
		var below: Dictionary = _stack.back()
		var below_page: UIFlowPage = below["instance"] as UIFlowPage
		if below_page and below_page.has_method("_on_shown"):
			below_page._on_shown()

	page_popped.emit(top_class)
	page_closed.emit(top_class)


## Replace the top page with a new one.
func replace(page_class: GDScript, data: Dictionary = {}, page_theme: UIFlowTheme = null) -> Control:
	if _stack.is_empty():
		return push(page_class, data, page_theme)

	# Pop old page (without lifecycle — we handle it here)
	var old: Dictionary = _stack.pop_back()
	var old_instance: Control = old["instance"]
	var old_page: UIFlowPage = old_instance as UIFlowPage
	if old_page and old_page.has_method("_on_closed"):
		old_page._on_closed()
	if old_page and old_page.has_method("_on_destroyed"):
		old_page._on_destroyed()
	_container.remove_child(old_instance)
	old_instance.queue_free()

	# Push new page
	return push(page_class, data, page_theme)


## Remove all pages except the root.
func pop_to_root() -> void:
	while _stack.size() > 1:
		pop()


## Find a page instance by class.
func get_page(page_class: GDScript) -> Control:
	for entry in _stack:
		if entry["class"] == page_class:
			return entry["instance"]
	return null


## Check if a page is in the stack.
func has_page(page_class: GDScript) -> bool:
	for entry in _stack:
		if entry["class"] == page_class:
			return true
	return false


## Get current top page class.
func current_page_class() -> GDScript:
	if _stack.is_empty():
		return null
	return _stack.back()["class"]


## Get current top page instance.
func current_page_instance() -> Control:
	if _stack.is_empty():
		return null
	return _stack.back()["instance"]


## Get stack depth.
func depth() -> int:
	return _stack.size()


## Get navigation path.
func navigation_path() -> Array[StringName]:
	var path: Array[StringName] = []
	for entry in _stack:
		path.append(entry["class"].get_global_name())
	return path
