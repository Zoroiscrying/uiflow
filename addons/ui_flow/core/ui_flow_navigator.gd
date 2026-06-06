## Navigation stack manager for UIFlow pages.
## Manages push/pop/replace operations and page lifecycle callbacks.
class_name UIFlowNavigator extends Node

## Emitted when a page is pushed onto the stack.
signal page_pushed(page_class: GDScript, data: Dictionary)
## Emitted when the top page is popped.
signal page_popped(page_class: GDScript)
## Emitted when the top page is replaced.
signal page_replaced(old_class: GDScript, new_class: GDScript, data: Dictionary)

var _stack: Array[Dictionary] = [] # Each entry: { "class": GDScript, "instance": Control, "scene": PackedScene }
var _scene_resolver: UIFlowSceneResolver
var _transition_manager: UIFlowTransitionManager
var _container: Control # Parent node for page instances


func setup(p_container: Control, p_resolver: UIFlowSceneResolver, p_transition_manager: UIFlowTransitionManager) -> void:
	_container = p_container
	_scene_resolver = p_resolver
	_transition_manager = p_transition_manager


## Push a new page onto the stack.
## Returns the page instance, allowing immediate custom initialization.
## [param page_class] is the GDScript class (e.g. SettingsPage).
## [param data] is passed to the page's [code]_on_enter()[/code] callback.
## [param transition] optionally overrides the default transition.
##
## Example:
## [codeblock]
## var page: SettingsPage = UIFlow.push(SettingsPage) as SettingsPage
## page.custom_init(some_data)
## [/codeblock]
func push(page_class: GDScript, data: Dictionary = {}, transition = null) -> Control:
	var scene: PackedScene = _scene_resolver.resolve(page_class)
	if scene == null:
		return null

	# Pause current top page
	if _stack.size() > 0:
		var current: Dictionary = _stack.back()
		var current_page: UIFlowPage = current["instance"] as UIFlowPage
		if current_page and current_page.has_method("_on_pause"):
			current_page._on_pause()
		# Play exit transition on current page (hide behind new page)
		if transition:
			_transition_manager.play_exit_instant(current_page)

	# Instantiate and add new page
	var instance: Control = scene.instantiate()
	_container.add_child(instance)
	instance.visible = false

	_stack.push_back({
		"class": page_class,
		"instance": instance,
		"scene": scene,
	})

	# Play enter transition
	var resolved_transition = _resolve_transition(transition)
	var page: UIFlowPage = instance as UIFlowPage
	_transition_manager.play_enter(instance, resolved_transition, func():
		if page and page.has_method("_on_enter"):
			page._on_enter(data)
		page_pushed.emit(page_class, data)
	)

	return instance


## Pop the top page off the stack, revealing the one below.
func pop(transition = null) -> void:
	if _stack.is_empty():
		push_warning("UIFlow: Navigation stack is empty, cannot pop.")
		return

	var top: Dictionary = _stack.pop_back()
	var top_instance: Control = top["instance"]
	var top_class: GDScript = top["class"]

	# Play exit transition
	var resolved_transition = _resolve_transition(transition)
	_transition_manager.play_exit(top_instance, resolved_transition, func():
		# Call lifecycle callback
		var page: UIFlowPage = top_instance as UIFlowPage
		if page and page.has_method("_on_exit"):
			page._on_exit()

		# Remove from tree
		_container.remove_child(top_instance)
		top_instance.queue_free()

		# Resume the page below
		if _stack.size() > 0:
			var below: Dictionary = _stack.back()
			var below_instance: Control = below["instance"]
			below_instance.visible = true
			var below_page: UIFlowPage = below_instance as UIFlowPage
			if below_page and below_page.has_method("_on_resume"):
				below_page._on_resume()

		page_popped.emit(top_class)
	)


## Replace the top page with a new one (doesn't increase stack depth).
## Returns the new page instance.
func replace(page_class: GDScript, data: Dictionary = {}, transition = null) -> Control:
	if _stack.is_empty():
		push(page_class, data, transition)
		return

	var old: Dictionary = _stack.back()
	var old_class: GDScript = old["class"]

	# Pop without lifecycle callback (we'll handle it)
	var old_instance: Control = old["instance"]
	_stack.pop_back()

	var resolved_transition = _resolve_transition(transition)
	_transition_manager.play_exit(old_instance, resolved_transition, func():
		var page: UIFlowPage = old_instance as UIFlowPage
		if page and page.has_method("_on_exit"):
			page._on_exit()
		_container.remove_child(old_instance)
		old_instance.queue_free()
	)

	# Push new page
	var scene: PackedScene = _scene_resolver.resolve(page_class)
	if scene == null:
		return

	var instance: Control = scene.instantiate()
	_container.add_child(instance)
	instance.visible = false

	_stack.push_back({
		"class": page_class,
		"instance": instance,
		"scene": scene,
	})

	_transition_manager.play_enter(instance, resolved_transition, func():
		var page: UIFlowPage = instance as UIFlowPage
		if page and page.has_method("_on_enter"):
			page._on_enter(data)
		page_replaced.emit(old_class, page_class, data)
	)

	return instance


## Remove all pages from the stack, optionally pushing a new root page.
func pop_to_root(transition = null) -> void:
	while _stack.size() > 1:
		var top: Dictionary = _stack.pop_back()
		var page: UIFlowPage = top["instance"] as UIFlowPage
		if page and page.has_method("_on_exit"):
			page._on_exit()
		_container.remove_child(top["instance"])
		top["instance"].queue_free()

	# Resume root page
	if _stack.size() > 0:
		var root_inst: Control = _stack.back()["instance"]
		root_inst.visible = true
		var root_page: UIFlowPage = root_inst as UIFlowPage
		if root_page and root_page.has_method("_on_resume"):
			root_page._on_resume()


## Get the class of the current top page.
func current_page_class() -> GDScript:
	if _stack.is_empty():
		return null
	return _stack.back()["class"]


## Get the current top page instance.
func current_page_instance() -> Control:
	if _stack.is_empty():
		return null
	return _stack.back()["instance"]


## Find a page instance in the stack by its class.
## Returns null if the page is not in the stack.
## Useful for accessing pages that are paused (covered by another page).
##
## Example:
## [codeblock]
## var settings: SettingsPage = UIFlow.get_page(SettingsPage) as SettingsPage
## if settings:
##     settings.refresh()
## [/codeblock]
func get_page(page_class: GDScript) -> Control:
	for entry in _stack:
		if entry["class"] == page_class:
			return entry["instance"]
	return null


## Check if a page of the given class is in the stack.
func has_page(page_class: GDScript) -> bool:
	for entry in _stack:
		if entry["class"] == page_class:
			return true
	return false


## Get the current stack depth.
func depth() -> int:
	return _stack.size()


## Get the full navigation path as an array of class names.
func navigation_path() -> Array[StringName]:
	var path: Array[StringName] = []
	for entry in _stack:
		var cls: GDScript = entry["class"]
		path.append(cls.get_global_name())
	return path


func _resolve_transition(transition) -> UIFlowTransitionBase:
	if transition == null:
		return _transition_manager.default_transition()
	if transition is UIFlowTransitionBase:
		return transition
	if transition is UIFlowTransitionType.Type:
		return _transition_manager.get_preset(transition)
	push_warning("UIFlow: Invalid transition type, using default.")
	return _transition_manager.default_transition()
