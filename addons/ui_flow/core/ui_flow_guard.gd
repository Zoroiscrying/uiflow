## UIFlowGuard — route guard system for conditional navigation.
##
## Guards are checked before a page is pushed. If any guard returns false,
## the navigation is blocked and an optional callback is called.
##
## Usage:
## [codeblock]
## # Add a guard that blocks navigation when player is in combat
## UIFlow.add_guard(func(from_page, to_page, data):
##     if Game.is_in_combat():
##         UIFlowUI.Toast.show_toast("Can't open menu during combat!", "warning")
##         return false
##     return true
## )
##
## # Add a guard for a specific page
## UIFlow.add_page_guard(SettingsPage, func(from_page, data):
##     if not Game.is_in_safe_zone():
##         return false
##     return true
## )
## [/codeblock]
class_name UIFlowGuard extends RefCounted

## Guard function type: (from_page: GDScript, to_page: GDScript, data: Variant) -> bool
## Return true to allow navigation, false to block.
## [param data] is the navigation payload passed to push()/replace().
var _global_guards: Array[Callable] = []

## Page-specific guards: page_class -> Array[Callable]
var _page_guards: Dictionary = {}


## Add a global guard that checks all navigation.
func add_guard(guard: Callable) -> void:
	_global_guards.append(guard)


## Remove a global guard.
func remove_guard(guard: Callable) -> void:
	_global_guards.erase(guard)


## Add a guard for a specific target page.
func add_page_guard(page_class: GDScript, guard: Callable) -> void:
	if not _page_guards.has(page_class):
		_page_guards[page_class] = []
	_page_guards[page_class].append(guard)


## Remove a page-specific guard.
func remove_page_guard(page_class: GDScript, guard: Callable) -> void:
	if _page_guards.has(page_class):
		_page_guards[page_class].erase(guard)


## Check if navigation is allowed. Returns true if allowed, false if blocked.
func can_navigate(from_page: GDScript, to_page: GDScript, data: Variant = null) -> bool:
	# Check global guards
	for guard in _global_guards:
		if guard.is_valid():
			var result = guard.call(from_page, to_page, data)
			if result == false:
				return false

	# Check page-specific guards
	if _page_guards.has(to_page):
		for guard in _page_guards[to_page]:
			if guard.is_valid():
				var result = guard.call(from_page, data)
				if result == false:
					return false

	return true


## Clear all guards.
func clear() -> void:
	_global_guards.clear()
	_page_guards.clear()
