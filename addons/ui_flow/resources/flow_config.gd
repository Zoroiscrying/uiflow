## Global UIFlow configuration resource.
## Create one of these in your project to customize UIFlow behavior.
## Settings can also be configured via Project Settings → UIFlow.
@tool
class_name UIFlowConfig extends Resource

@export var scene_directory: String = "res://UIScene/"
@export var default_transition: UIFlowTransitionType.Type = UIFlowTransitionType.Type.FADE
@export var default_transition_duration: float = 0.3
@export var back_action: StringName = &"ui_cancel"
@export var auto_focus_on_push: bool = true
@export var restore_focus_on_pop: bool = true

## If true, ui_left/right/up/down (arrow keys, d-pad, left stick) move focus
## between focusable controls on the top page. Explicit focus_neighbor_*
## assignments win over automatic geometry-based search.
@export var enable_directional_focus: bool = true

## If true, directional focus wraps around to the opposite edge when no
## candidate exists in the pressed direction; if false, focus is trapped.
@export var focus_wrap_enabled: bool = false

## Maximum navigation stack depth before pushing new pages is blocked.
## Prevents accidental memory leaks from unbounded push loops.
@export_range(1, 200, 1) var max_stack_depth: int = 50

## If true, pressing back on a modal page without an _on_back handler will pop it.
## If false, modal pages swallow the back input and stay open.
@export var modal_close_on_back: bool = true

## If true, frequently used pages are recycled instead of freed.
## Reduces GC pressure for pages that are opened/closed often (backpack, shop, etc.).
@export var enable_object_pooling: bool = false

## Maximum number of pooled instances per page class.
@export_range(1, 20, 1) var max_pool_size: int = 5

## Default theme name applied on startup ("dark", "light", or a custom registered name).
@export var default_theme_name: String = "dark"

## Optional page class shown while an async page is loading.
## If empty, no loading page is shown.
@export var loading_page_class: GDScript = null
