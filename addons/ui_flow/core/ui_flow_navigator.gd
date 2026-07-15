## Navigation stack manager for UIFlow pages.
## Manages push/pop/replace operations and page lifecycle.
## Pages handle their own animations via _on_opened/_on_closed callbacks.
##
## Navigation is protected by a lock (_is_navigating) to prevent race conditions
## during animations. Concurrent requests are queued and executed sequentially.
class_name UIFlowNavigator extends Node

signal page_pushed(page_class: GDScript, data: Variant)
signal page_popped(page_class: GDScript)
signal page_opened(page_class: GDScript)   # Emitted when enter animation + _on_after_opened completes
signal page_closed(page_class: GDScript)     # Emitted when exit animation + cleanup completes

var _stack: Array[Dictionary] = [] # { "class": GDScript, "instance": Control, "scene": PackedScene }
var _scene_resolver: UIFlowSceneResolver
var _container: Control
const _GuardClass = preload("res://addons/ui_flow/core/ui_flow_guard.gd")
var _guard  # UIFlowGuard

## True when a navigation operation is in progress (animation playing).
## Prevents concurrent push/pop/replace/close operations.
var _is_navigating: bool = false

## Queue of pending navigation operations (Callables) when _is_navigating is true.
var _pending_navigations: Array[Callable] = []

## Maps modal page instances to their full-screen input blocker overlays.
var _modal_overlays: Dictionary = {}


func setup(p_container: Control, p_resolver: UIFlowSceneResolver) -> void:
	_container = p_container
	_scene_resolver = p_resolver
	_guard = _GuardClass.new()


## Get the guard system for adding navigation guards.
func get_guard():
	return _guard


# ── Navigation lock / queue ──────────────────────────────────────────────────

## Try to acquire the navigation lock. Returns true if acquired, false if busy.
func _start_navigation() -> bool:
	if _is_navigating:
		return false
	_is_navigating = true
	return true


## Release the navigation lock and process the next queued operation.
func _finish_navigation() -> void:
	_is_navigating = false
	_process_pending()


## Process the next queued navigation operation, if any.
func _process_pending() -> void:
	if _is_navigating or _pending_navigations.is_empty():
		return
	var next: Callable = _pending_navigations.pop_front()
	next.call()


## Queue a navigation operation when the lock is busy.
func _queue_navigation(callable: Callable) -> void:
	_pending_navigations.append(callable)


# ── Modal overlay system ─────────────────────────────────────────────────────

## Setup a full-screen input blocker behind the modal page to intercept events below it.
func _setup_input_blocker(page: UIFlowPage) -> void:
	if not page or page.is_modal == false:
		return
	if _modal_overlays.has(page):
		return

	var blocker := ColorRect.new()
	blocker.name = "UIFlowModalOverlay"
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.color = Color.TRANSPARENT
	blocker.z_index = 0

	# Add the blocker to the page container, just behind the modal page.
	_container.add_child(blocker)
	if page.is_inside_tree():
		var page_index: int = page.get_index()
		_container.move_child(blocker, page_index)
	_modal_overlays[page] = blocker


## Remove the input blocker associated with a modal page.
func _remove_input_blocker(page: UIFlowPage) -> void:
	if not page:
		return
	var blocker: Node = _modal_overlays.get(page)
	if is_instance_valid(blocker) and blocker.is_inside_tree():
		# Use free() so the overlay is removed immediately; tests and callers
		# expect it to disappear before the navigation operation completes.
		blocker.free()
	_modal_overlays.erase(page)


# ── Push ─────────────────────────────────────────────────────────────────────

## Push a new page onto the stack.
## If the page is already in the stack, moves it to the top.
## Returns the page instance. Returns null if blocked by a guard or busy.
func push(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null) -> Control:
	if not _start_navigation():
		_queue_navigation(func():
			push(page_class, data, page_theme)
		)
		return null

	var result := _do_push(page_class, data, page_theme)
	return result


## Push a page with asynchronous scene loading.
## Returns the page instance once it has been opened.
func push_async(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null) -> Control:
	if not _start_navigation():
		_queue_navigation(func():
			push_async(page_class, data, page_theme)
		)
		return null

	# Load the scene asynchronously. The lock is held so concurrent navigation waits.
	var scene: PackedScene = await _scene_resolver.resolve_async(page_class)
	if scene == null:
		_finish_navigation()
		return null

	var result := _do_push(page_class, data, page_theme)
	return result


## Push a page asynchronously, showing a loading page while the scene loads.
## If [param loading_page_class] is null, falls back to UIFlow.Config.loading_page_class.
## The loading page is pushed normally, then the target page is pushed on top once ready,
## and finally the loading page is removed.
func push_async_with_loading(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null, loading_page_class: GDScript = null) -> Control:
	if not _start_navigation():
		_queue_navigation(func():
			push_async_with_loading(page_class, data, page_theme, loading_page_class)
		)
		return null

	var loading_class := loading_page_class
	if loading_class == null and UIFlow.Config != null:
		loading_class = UIFlow.Config.loading_page_class

	# Push loading page synchronously while holding the navigation lock.
	# p_finish_navigation is false so the lock stays held across the async await.
	var loading_instance: Control = null
	if loading_class != null:
		loading_instance = _do_push(loading_class, {}, null, false)

	# Load target scene asynchronously. Forward load progress to the loading
	# page when it implements set_progress(float) (0.0–1.0, always ends at 1.0).
	var progress_cb := Callable()
	if loading_instance != null and loading_instance.has_method("set_progress"):
		progress_cb = func(p: float) -> void:
			if is_instance_valid(loading_instance):
				loading_instance.set_progress(p)
	var scene: PackedScene = await _scene_resolver.resolve_async(page_class, progress_cb)
	if scene == null:
		if loading_instance != null:
			_pop_and_cleanup(loading_instance, loading_class)
		_finish_navigation()
		return null

	# Push target page. This releases the navigation lock once the target opens.
	var result := _do_push(page_class, data, page_theme, true)

	# Remove the loading page once the target has opened.
	if loading_instance != null:
		var target_opened := false
		var on_opened := func(c: GDScript):
			if c == page_class:
				target_opened = true
		page_opened.connect(on_opened)
		while _is_navigating and not target_opened:
			await page_opened
		page_opened.disconnect(on_opened)
		_remove_loading_page(loading_instance, loading_class)

	return result


## Remove a specific page instance from the stack without playing an exit animation.
## Used internally by push_async_with_loading to clean up the loading page.
func _remove_loading_page(instance: Control, page_class: GDScript) -> void:
	for i in range(_stack.size()):
		if _stack[i]["class"] == page_class and _stack[i]["instance"] == instance:
			_stack.remove_at(i)
			var page: UIFlowPage = instance as UIFlowPage
			if page:
				_remove_input_blocker(page)
				if page.has_meta("_uiflow_mouse_filter"):
					page.mouse_filter = page.get_meta("_uiflow_mouse_filter")
					page.remove_meta("_uiflow_mouse_filter")
				page._state = UIFlowPage.State.CLOSED
				page._unbind_all()
				if page.has_method("_on_closed"):
					page._on_closed()
				if page.has_method("_on_destroyed"):
					page._on_destroyed()
				page._state = UIFlowPage.State.DESTROYED

			var pooled := false
			if page_class is GDScript and _scene_resolver != null:
				pooled = _scene_resolver.release_to_pool(page_class, instance)

			if not pooled:
				if is_instance_valid(instance) and instance.is_inside_tree():
					_container.remove_child(instance)
					instance.queue_free()
			else:
				if is_instance_valid(instance) and instance.is_inside_tree():
					_container.remove_child(instance)

			page_popped.emit(page_class)
			page_closed.emit(page_class)
			return


## Pop the top page and run cleanup immediately. Used when a loading page must be
## removed after an async load fails.
func _pop_and_cleanup(instance: Control, page_class: GDScript) -> void:
	if _stack.is_empty():
		return
	var top: Dictionary = _stack.pop_back()
	_cleanup_after_pop(top["instance"], top["class"])


## Internal push implementation. Assumes navigation lock is held.
## [param p_finish_navigation] controls whether this operation releases the
## navigation lock on completion. Pass false when the caller holds the lock
## across multiple steps (e.g. push_async_with_loading).
func _do_push(page_class: GDScript, data: Variant, page_theme: UIFlowTheme, p_finish_navigation: bool = true) -> Control:
	# If already in stack, move to top (no animation needed, no lock needed)
	var existing := get_page(page_class)
	if existing:
		_move_to_top(page_class)
		if p_finish_navigation:
			_finish_navigation()
		return existing

	# Check max stack depth
	var max_depth: int = UIFlow.Config.max_stack_depth if UIFlow.Config else 50
	if _stack.size() >= max_depth:
		push_warning("UIFlow: Max stack depth (%d) reached, cannot push new page." % max_depth)
		if p_finish_navigation:
			_finish_navigation()
		return null

	# Check guards
	var from_class: GDScript = current_page_class()
	if _guard and not _guard.can_navigate(from_class, page_class, data):
		if p_finish_navigation:
			_finish_navigation()
		return null

	var scene: PackedScene = _scene_resolver.resolve(page_class)
	if scene == null:
		if p_finish_navigation:
			_finish_navigation()
		return null

	# Notify current top page it's being hidden
	if _stack.size() > 0:
		var current: Dictionary = _stack.back()
		var current_page: UIFlowPage = current["instance"] as UIFlowPage
		if current_page and is_instance_valid(current_page) and current_page.has_method("_on_hidden"):
			if UIFlow.Focus != null:
				UIFlow.Focus.remember_focus(current_page)
			current_page._on_hidden()
			current_page._state = UIFlowPage.State.HIDDEN
			current_page.set_process_input(false)
			current_page.set_process_unhandled_input(false)

	# Try to acquire from object pool
	var instance: Control = _scene_resolver.acquire_pooled(page_class)
	var page: UIFlowPage = null
	if instance != null:
		page = instance as UIFlowPage
		# Reset state for reuse
		if page:
			page._state = UIFlowPage.State.IDLE
	else:
		# Instantiate new
		instance = scene.instantiate()
		page = instance as UIFlowPage

	# Lifecycle: created (before add_child, so user can configure position etc.)
	if page and page.has_method("_on_created"):
		page._state = UIFlowPage.State.CREATING
		page._on_created(data)

	# Check if the enter effect wants the node to start hidden
	var starts_hidden := false
	if page and page.enter_effect:
		if page.enter_effect.starts_hidden:
			starts_hidden = true
	instance.visible = not starts_hidden
	if not instance.is_inside_tree():
		_container.add_child(instance)

	# Show modal overlay if this page is modal
	if page and page.is_modal:
		page.set_meta("_uiflow_mouse_filter", page.mouse_filter)
		page.mouse_filter = Control.MOUSE_FILTER_STOP
		_setup_input_blocker(page)

	# Apply theme
	if page_theme:
		instance.theme = page_theme.build_godot_theme()

	_stack.push_back({
		"class": page_class,
		"instance": instance,
		"scene": scene,
	})

	# Lifecycle: opened (after add_child, before animation)
	if page and page.has_method("_on_opened"):
		page._on_opened(data)

	# Play enter animation, then finish
	if page:
		var current_instance: Control = null
		if _stack.size() > 1:
			current_instance = _stack[_stack.size() - 2]["instance"] as Control

		var shared_effect := page.enter_effect as UIFlowSharedElementTransition
		if shared_effect != null and current_instance != null:
			page._state = UIFlowPage.State.ENTERING
			shared_effect.play_enter_with_partner(current_instance, instance, func():
				if is_instance_valid(page):
					page._state = UIFlowPage.State.OPENED
					page._apply_default_focus()
					if page.has_method("_on_after_opened"):
						page._on_after_opened()
				page_opened.emit(page_class)
				if p_finish_navigation:
					_finish_navigation()
			)
		else:
			page._play_enter_animation(func():
				if is_instance_valid(page):
					page._state = UIFlowPage.State.OPENED
					page._apply_default_focus()
					if page.has_method("_on_after_opened"):
						page._on_after_opened()
				page_opened.emit(page_class)
				if p_finish_navigation:
					_finish_navigation()
			)
	else:
		page_opened.emit(page_class)
		if p_finish_navigation:
			_finish_navigation()

	page_pushed.emit(page_class, data)
	return instance


## Push a pre-instantiated page instance.
func push_instance(instance: Control, data: Variant = null) -> Control:
	if not _start_navigation():
		_queue_navigation(func():
			push_instance(instance, data)
		)
		return null

	var result := _do_push_instance(instance, data)
	return result


func _do_push_instance(instance: Control, data: Variant) -> Control:
	# Check max stack depth
	var max_depth: int = UIFlow.Config.max_stack_depth if UIFlow.Config else 50
	if _stack.size() >= max_depth:
		push_warning("UIFlow: Max stack depth (%d) reached, cannot push new page." % max_depth)
		_finish_navigation()
		return null

	# Check guards
	var from_class: GDScript = current_page_class()
	var to_class: GDScript = instance.get_script() as GDScript
	if _guard and not _guard.can_navigate(from_class, to_class, data):
		_finish_navigation()
		return null

	if _stack.size() > 0:
		var current: Dictionary = _stack.back()
		var current_page: UIFlowPage = current["instance"] as UIFlowPage
		if current_page and is_instance_valid(current_page) and current_page.has_method("_on_hidden"):
			if UIFlow.Focus != null:
				UIFlow.Focus.remember_focus(current_page)
			current_page._on_hidden()
			current_page._state = UIFlowPage.State.HIDDEN
			current_page.set_process_input(false)
			current_page.set_process_unhandled_input(false)

	var page: UIFlowPage = instance as UIFlowPage

	# Lifecycle: created (before add_child)
	if page and page.has_method("_on_created"):
		page._state = UIFlowPage.State.CREATING
		page._on_created(data)

	instance.visible = true
	instance.modulate.a = 1.0
	_container.add_child(instance)

	# Show modal overlay if this page is modal
	if page and page.is_modal:
		page.set_meta("_uiflow_mouse_filter", page.mouse_filter)
		page.mouse_filter = Control.MOUSE_FILTER_STOP
		_setup_input_blocker(page)

	_stack.push_back({
		"class": instance.get_script(),
		"instance": instance,
		"scene": null,
	})

	# Lifecycle: opened
	if page and page.has_method("_on_opened"):
		page._on_opened(data)

	# Play enter animation
	if page:
		page._play_enter_animation(func():
			if is_instance_valid(page):
				page._state = UIFlowPage.State.OPENED
				page._apply_default_focus()
				if page.has_method("_on_after_opened"):
					page._on_after_opened()
			page_opened.emit(instance.get_script())
			_finish_navigation()
		)
	else:
		page_opened.emit(instance.get_script())
		_finish_navigation()

	page_pushed.emit(instance.get_script(), data)
	return instance


# ── Pop / Close ────────────────────────────────────────────────────────────────

## Pop the top page off the stack.
func pop() -> void:
	if _stack.is_empty():
		push_warning("UIFlow: Navigation stack is empty, cannot pop.")
		return

	if not _start_navigation():
		_queue_navigation(func():
			pop()
		)
		return

	var top: Dictionary = _stack.pop_back()
	var top_instance: Control = top["instance"]
	var top_class: GDScript = top["class"]

	# Lifecycle: before closed (before exit animation)
	var page: UIFlowPage = top_instance as UIFlowPage
	if page and page.has_method("_on_before_closed"):
		page._on_before_closed()

	# Play exit animation, then clean up
	if page:
		var below_instance: Control = null
		if _stack.size() > 0:
			below_instance = _stack.back()["instance"] as Control

		var shared_exit := page.exit_effect as UIFlowSharedElementTransition
		if shared_exit != null and below_instance != null:
			page._state = UIFlowPage.State.EXITING
			below_instance.visible = true
			shared_exit.play_exit_with_partner(top_instance, below_instance, func():
				_cleanup_after_pop(top_instance, top_class)
				_finish_navigation()
			)
		else:
			page._play_exit_animation(func():
				_cleanup_after_pop(top_instance, top_class)
				_finish_navigation()
			)
	else:
		_cleanup_after_pop(top_instance, top_class)
		_finish_navigation()


func _cleanup_after_pop(top_instance: Control, top_class: GDScript) -> void:
	# Remove modal overlay if present
	var page: UIFlowPage = top_instance as UIFlowPage
	if page:
		_remove_input_blocker(page)
		# Restore original mouse_filter if it was changed for modal
		if page.has_meta("_uiflow_mouse_filter"):
			page.mouse_filter = page.get_meta("_uiflow_mouse_filter")
			page.remove_meta("_uiflow_mouse_filter")
		page._state = UIFlowPage.State.CLOSED
		page._unbind_all()
		if page.has_method("_on_closed"):
			page._on_closed()
		if page.has_method("_on_destroyed"):
			page._on_destroyed()
		page._state = UIFlowPage.State.DESTROYED
		if UIFlow.Focus != null:
			UIFlow.Focus.forget_focus(page)

	# Try to pool the instance instead of freeing
	var pooled := false
	if top_class is GDScript and _scene_resolver != null:
		pooled = _scene_resolver.release_to_pool(top_class, top_instance)

	if not pooled:
		if is_instance_valid(top_instance) and top_instance.is_inside_tree():
			_container.remove_child(top_instance)
			top_instance.queue_free()
		if page:
			page._state = UIFlowPage.State.DESTROYED
	else:
		# Instance was pooled: remove from tree but don't free
		if is_instance_valid(top_instance) and top_instance.is_inside_tree():
			_container.remove_child(top_instance)
		if page:
			page._state = UIFlowPage.State.IDLE

	# Notify page below
	if _stack.size() > 0:
		var below: Dictionary = _stack.back()
		var below_page: UIFlowPage = below["instance"] as UIFlowPage
		if below_page and is_instance_valid(below_page):
			if below_page.has_method("_on_shown"):
				below_page._on_shown()
			if below_page._state == UIFlowPage.State.HIDDEN:
				below_page._state = UIFlowPage.State.OPENED
				below_page.set_process_input(true)
				below_page.set_process_unhandled_input(true)
			if UIFlow.Focus != null:
				UIFlow.Focus.restore_focus(below_page)

	page_popped.emit(top_class)
	page_closed.emit(top_class)


## Replace the top page with a new one.
func replace(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null) -> Control:
	if not _start_navigation():
		_queue_navigation(func():
			replace(page_class, data, page_theme)
		)
		return null

	if _stack.is_empty():
		var result := _do_push(page_class, data, page_theme)
		return result

	# Pop old page (without lifecycle — we handle it here)
	var old: Dictionary = _stack.pop_back()
	var old_instance: Control = old["instance"]
	var old_page: UIFlowPage = old_instance as UIFlowPage
	if old_page:
		_remove_input_blocker(old_page)
		old_page._unbind_all()
		if old_page.has_method("_on_before_closed"):
			old_page._on_before_closed()
		if old_page.has_method("_on_closed"):
			old_page._on_closed()
		if old_page.has_method("_on_destroyed"):
			old_page._on_destroyed()
		old_page._state = UIFlowPage.State.DESTROYED
		if UIFlow.Focus != null:
			UIFlow.Focus.forget_focus(old_page)
	_container.remove_child(old_instance)
	old_instance.queue_free()

	# Push new page (lock already held, call internal directly)
	var result := _do_push(page_class, data, page_theme)
	return result


## Remove all pages except the root.
func pop_to_root() -> void:
	if not _start_navigation():
		_queue_navigation(func():
			pop_to_root()
		)
		return

	# Stack is empty or only root — nothing to do
	if _stack.size() <= 1:
		_finish_navigation()
		return

	# Remove all pages above root, top-to-bottom (no animation for middle pages).
	# The root stays at index 0, so we pop from the back.
	while _stack.size() > 1:
		var entry: Dictionary = _stack.pop_back()
		var instance: Control = entry["instance"]
		var page: UIFlowPage = instance as UIFlowPage
		if page:
			_remove_input_blocker(page)
			page._state = UIFlowPage.State.CLOSED
			page._unbind_all()
			if page.has_method("_on_closed"):
				page._on_closed()
			if page.has_method("_on_destroyed"):
				page._on_destroyed()
			page._state = UIFlowPage.State.DESTROYED
			if UIFlow.Focus != null:
				UIFlow.Focus.forget_focus(page)
		if is_instance_valid(instance) and instance.is_inside_tree():
			_container.remove_child(instance)
			instance.queue_free()

	# Now only root remains; notify it
	var root: Dictionary = _stack.back()
	var root_page: UIFlowPage = root["instance"] as UIFlowPage
	if root_page and is_instance_valid(root_page):
		if root_page.has_method("_on_shown"):
			root_page._on_shown()
		if root_page._state == UIFlowPage.State.HIDDEN:
			root_page._state = UIFlowPage.State.OPENED
			root_page.set_process_input(true)
			root_page.set_process_unhandled_input(true)
		if UIFlow.Focus != null:
			UIFlow.Focus.restore_focus(root_page)

	_finish_navigation()


## Close a specific page by class, anywhere in the stack.
## If the page is the top page, plays exit animation first.
## If the page is in the middle, removes it directly.
func close(page_class: GDScript) -> void:
	if _stack.is_empty():
		return

	# Find the page in the stack
	var target_index := -1
	for i in range(_stack.size()):
		if _stack[i]["class"] == page_class:
			target_index = i
			break

	if target_index == -1:
		push_warning("UIFlow: Page class not found in stack, cannot close.")
		return

	# If it's the top page, use pop() for proper exit animation
	if target_index == _stack.size() - 1:
		pop()
		return

	# Otherwise, remove directly
	var entry: Dictionary = _stack[target_index]
	var instance: Control = entry["instance"]
	var page: UIFlowPage = instance as UIFlowPage

	_stack.remove_at(target_index)

	if page:
		_remove_input_blocker(page)
		page._state = UIFlowPage.State.CLOSED
		page._unbind_all()
		if page.has_method("_on_closed"):
			page._on_closed()
		if page.has_method("_on_destroyed"):
			page._on_destroyed()
		page._state = UIFlowPage.State.DESTROYED
		if UIFlow.Focus != null:
			UIFlow.Focus.forget_focus(page)

	if is_instance_valid(instance) and instance.is_inside_tree():
		_container.remove_child(instance)
		instance.queue_free()

	page_closed.emit(page_class)


# ── Stack queries ────────────────────────────────────────────────────────────

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


## Check if a page is the top page in the stack.
func is_on_top(page_class: GDScript) -> bool:
	if _stack.is_empty():
		return false
	return _stack.back()["class"] == page_class


## Move an existing page to the top of the stack.
## Calls _on_hidden on the current top, moves the page, calls _on_shown.
func _move_to_top(page_class: GDScript) -> void:
	var target_index := -1
	for i in range(_stack.size()):
		if _stack[i]["class"] == page_class:
			target_index = i
			break

	if target_index == -1 or target_index == _stack.size() - 1:
		return  # Not found or already on top

	# Notify current top it's being hidden
	var current_top: Dictionary = _stack.back()
	var current_page: UIFlowPage = current_top["instance"] as UIFlowPage
	if current_page and is_instance_valid(current_page) and current_page.has_method("_on_hidden"):
		if UIFlow.Focus != null:
			UIFlow.Focus.remember_focus(current_page)
		current_page._on_hidden()
		current_page._state = UIFlowPage.State.HIDDEN
		current_page.set_process_input(false)
		current_page.set_process_unhandled_input(false)

	# Move to top
	var entry: Dictionary = _stack[target_index]
	_stack.remove_at(target_index)
	_stack.push_back(entry)

	# Bring to front in the scene tree
	var instance: Control = entry["instance"]
	if instance.is_inside_tree():
		_container.move_child(instance, _container.get_child_count() - 1)

	# Notify moved page it's now shown
	var moved_page: UIFlowPage = instance as UIFlowPage
	if moved_page and is_instance_valid(moved_page):
		if moved_page.has_method("_on_shown"):
			moved_page._on_shown()
		if moved_page._state == UIFlowPage.State.HIDDEN:
			moved_page._state = UIFlowPage.State.OPENED
			moved_page.set_process_input(true)
			moved_page.set_process_unhandled_input(true)
		if UIFlow.Focus != null:
			UIFlow.Focus.restore_focus(moved_page)


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
