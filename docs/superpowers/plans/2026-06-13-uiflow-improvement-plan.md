# UIFlow Plugin Improvement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix bugs, complete half-finished systems, add tests, improve documentation, and enhance editor tooling for the UIFlow plugin.

**Architecture:** Incremental improvements to existing codebase. Each task is self-contained and can be verified independently.

**Tech Stack:** Godot 4.6, GDScript, gdUnit4

**Analysis Source:** Comprehensive codebase review identified 5 categories of work.

---

## Phase 1: Bug Fixes

### Task 1: Fix AlertDialog Signal Leak

**Files:**
- Modify: `addons/ui_flow/components/alert_dialog.gd`

**Problem:** `show_alert()` connects `on_close` to the OK button each time without disconnecting previous connections. Multiple calls accumulate handlers.

- [ ] **Step 1: Read current code**

Read `addons/ui_flow/components/alert_dialog.gd`, find the `show_alert` method.

- [ ] **Step 2: Fix signal connection**

The OK button's `pressed` signal should only have one connection. Before connecting, disconnect any existing connection, or use `CONNECT_ONE_SHOT`.

```gdscript
# In show_alert(), replace the button connection with:
if _ok_button.pressed.is_connected(_on_ok_pressed):
    _ok_button.pressed.disconnect(_on_ok_pressed)
_on_ok_pressed = on_close
_ok_button.pressed.connect(_on_ok_pressed, CONNECT_ONE_SHOT)
```

Or simpler: clear all connections before connecting:
```gdscript
# At the start of show_alert():
_ok_button.pressed.disconnect_all()
if on_close.is_valid():
    _ok_button.pressed.connect(on_close)
_ok_button.pressed.connect(func(): close())
```

- [ ] **Step 3: Test manually**

Call `show_alert` twice in succession, verify only one handler fires.

- [ ] **Step 4: Commit**

```bash
git add addons/ui_flow/components/alert_dialog.gd
git commit -m "fix: AlertDialog signal leak — disconnect previous handler before reconnect"
```

---

### Task 2: Fix ItemSlot Drag-Drop Signal Timing

**Files:**
- modify: `addons/ui_flow/components/item_slot.gd`

**Problem:** `_on_drag_dropped` emits `item_dragged` after `_item` is set to null. Signal should emit before clearing.

- [ ] **Step 1: Read current code**

Read `item_slot.gd`, find `_on_drag_dropped`.

- [ ] **Step 2: Fix signal emission order**

```gdscript
func _on_drag_dropped(target) -> void:
    var dragged_item := _item
    set_item(null)
    item_dragged.emit(dragged_item, slot_index)
```

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/components/item_slot.gd
git commit -m "fix: ItemSlot emits item_dragged before clearing item"
```

---

### Task 3: Fix Plugin Template Lifecycle Methods

**Files:**
- modify: `addons/ui_flow/editor/page_template.gd`
- modify: `addons/ui_flow/plugin.gd` (template string in `_create_page_template`)

**Problem:** Generated page template uses `_on_enter`/`_on_exit`/`_on_pause`/`_on_resume` which don't match the actual lifecycle: `_on_created`/`_on_opened`/`_on_hidden`/`_on_shown`/`_on_closed`/`_on_destroyed`.

- [ ] **Step 1: Read current template**

Read `page_template.gd` and the template string in `plugin.gd`.

- [ ] **Step 2: Update page_template.gd**

Replace the lifecycle methods:
- `_on_enter(data)` → `_on_opened(data)`
- `_on_exit()` → `_on_closed()`
- `_on_pause()` → `_on_hidden()`
- `_on_resume()` → `_on_shown()`

- [ ] **Step 3: Update plugin.gd template string**

Find the template string in `_create_page_template()` and apply the same method name changes.

- [ ] **Step 4: Test**

Use the editor tool menu to create a new page, verify it has the correct lifecycle methods.

- [ ] **Step 5: Commit**

```bash
git add addons/ui_flow/editor/page_template.gd addons/ui_flow/plugin.gd
git commit -m "fix: page template uses correct lifecycle method names"
```

---

### Task 4: Fix Naming Convention Violations

**Files:**
- modify: `addons/ui_flow/core/ui_flow_utils.gd`

**Problem:** `find_childByType`, `find_childrenByType`, `find_childByName`, `reserve_childrenFactory` use camelCase instead of GDScript snake_case.

- [ ] **Step 1: Read current code**

Read `ui_flow_utils.gd`, identify all methods with incorrect naming.

- [ ] **Step 2: Add snake_case aliases**

For each incorrectly named method, add a snake_case alias that calls the original:

```gdscript
## Use find_child_by_type instead.
func find_childByType(node: Node, type: Variant) -> Node:
    return find_child_by_type(node, type)

## Find first child of given type.
func find_child_by_type(node: Node, type: Variant) -> Node:
    # ... existing implementation
```

Keep old names as deprecated aliases for backwards compatibility.

- [ ] **Step 3: Update internal usage**

Search for internal calls to the old names and update them to use the new snake_case versions.

- [ ] **Step 4: Commit**

```bash
git add addons/ui_flow/core/ui_flow_utils.gd
git commit -m "fix: add snake_case aliases for camelCase utility methods"
```

---

### Task 5: Fix HoverHint Duplicate Code

**Files:**
- modify: `addons/ui_flow/components/hover_hint.gd`

**Problem:** `_set_text` has identical branches for BBCode vs non-BBCode.

- [ ] **Step 1: Read and simplify**

```gdscript
func _set_text(text: String) -> void:
    if use_bbcode:
        _label.bbcode_enabled = true
        _label.text = text
    else:
        _label.bbcode_enabled = false
        _label.text = text
```

Simplify to:
```gdscript
func _set_text(text: String) -> void:
    _label.bbcode_enabled = use_bbcode
    _label.text = text
```

- [ ] **Step 2: Commit**

```bash
git add addons/ui_flow/components/hover_hint.gd
git commit -m "fix: simplify HoverHint _set_text — remove duplicate branches"
```

---

## Phase 2: Complete Half-Finished Systems

### Task 6: Wire FlowConfig into UIFlow System

**Files:**
- modify: `addons/ui_flow/core/ui_flow_autoload.gd`
- modify: `addons/ui_flow/resources/flow_config.gd`

**Problem:** `UIFlowConfig` resource exists but is never loaded or used.

- [ ] **Step 1: Read current FlowConfig**

Read `flow_config.gd` to understand its properties.

- [ ] **Step 2: Add config loading to UIFlowAutoload**

In `_ready()` of `ui_flow_autoload.gd`, add:

```gdscript
var _config: UIFlowConfig

func _ready() -> void:
    _load_config()
    # ... existing code

func _load_config() -> void:
    var config_path := "res://ui_flow_config.tres"
    if ResourceLoader.exists(config_path):
        _config = load(config_path) as UIFlowConfig
    if _config == null:
        _config = UIFlowConfig.new()
```

- [ ] **Step 3: Use config values**

Update `_ensure_page_container()` to use `_config.scene_directory` if set:
```gdscript
func _ensure_page_container() -> void:
    # ... existing code
    Router.setup(_page_container, Scenes)
    if _config and not _config.scene_directory.is_empty():
        Scenes._scene_dir = _config.scene_directory
```

Update the input handler to use `_config.back_action` if set.

- [ ] **Step 4: Add @export properties to FlowConfig**

Ensure FlowConfig has all necessary properties:
```gdscript
@export var scene_directory: String = ""
@export var back_action: StringName = &"ui_cancel"
@export var default_transition: UIFlowTransitionType.Type = UIFlowTransitionType.Type.NONE
@export var default_transition_duration: float = 0.3
@export var auto_focus_on_push: bool = true
@export var restore_focus_on_pop: bool = true
```

- [ ] **Step 5: Commit**

```bash
git add addons/ui_flow/core/ui_flow_autoload.gd addons/ui_flow/resources/flow_config.gd
git commit -m "feat: wire FlowConfig into UIFlow system — scene dir, back action, defaults"
```

---

### Task 7: Wire UIInputActionManager into Input Handler

**Files:**
- modify: `addons/ui_flow/core/ui_flow_input_handler.gd`
- modify: `addons/ui_flow/core/ui_flow_input_action_manager.gd`

**Problem:** UIInputActionManager exists but isn't integrated into the input handling flow.

- [ ] **Step 1: Read both files**

Understand the current input handler flow and the action manager API.

- [ ] **Step 2: Add action manager to input handler**

In `ui_flow_input_handler.gd`:

```gdscript
var _action_manager: UIInputActionManager

func setup(navigator: UIFlowNavigator) -> void:
    _navigator = navigator
    _action_manager = UIInputActionManager.new()
    add_child(_action_manager)
```

- [ ] **Step 3: Route input through action manager**

In `_unhandled_input`, before processing back/cancel, check if the top page has registered actions:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if _navigator == null:
        return

    # Check page-specific actions first
    var top_page := _get_top_page()
    if top_page:
        _action_manager.process_input(event, top_page.get_all_actions())

    # Then handle back/cancel
    if not event.is_action_pressed("ui_cancel"):
        return
    # ... existing back handling
```

- [ ] **Step 4: Add get_prompts() support**

Add a method to get input prompts for the current page:

```gdscript
func get_current_prompts() -> Array:
    var top_page := _get_top_page()
    if top_page:
        return top_page.get_input_prompts()
    return []
```

- [ ] **Step 5: Commit**

```bash
git add addons/ui_flow/core/ui_flow_input_handler.gd addons/ui_flow/core/ui_flow_input_action_manager.gd
git commit -m "feat: wire UIInputActionManager into input handler for action routing"
```

---

## Phase 3: Unit Tests

### Task 8: Add Tests for UIFlowNavigator

**Files:**
- create: `tests/unit/core/test_ui_flow_navigator.gd`

Tests already exist but verify they cover:
- push/pop/replace
- guard system
- duplicate prevention
- lifecycle callbacks

- [ ] **Step 1: Read existing tests**

Check what's already covered.

- [ ] **Step 2: Add missing test cases**

Add tests for:
- `pop_to_root()` with multiple pages
- Guard blocking navigation
- `_on_hidden`/`_on_shown` lifecycle during push/pop
- `replace()` with empty stack

- [ ] **Step 3: Run tests**

```bash
F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd --add res://tests/unit/core/test_ui_flow_navigator.gd
```

- [ ] **Step 4: Commit**

```bash
git add tests/unit/core/test_ui_flow_navigator.gd
git commit -m "test: add navigator tests for guards, lifecycle, pop_to_root"
```

---

### Task 9: Add Tests for UIFlowBindUtils

**Files:**
- modify: `tests/unit/core/test_ui_flow_bind_utils.gd`

- [ ] **Step 1: Read existing tests**

- [ ] **Step 2: Add tests for:**
- `bind_multi()` — multiple signals to one property
- `bind_format()` — format string binding
- `unbind()` disconnects properly
- Multiple bindings on same node

- [ ] **Step 3: Run tests**

- [ ] **Step 4: Commit**

```bash
git add tests/unit/core/test_ui_flow_bind_utils.gd
git commit -m "test: add bind_multi, bind_format, and unbind tests"
```

---

### Task 10: Add Tests for UIFlowTheme

**Files:**
- modify: `tests/unit/core/test_ui_flow_theme.gd`

- [ ] **Step 1: Read existing tests**

- [ ] **Step 2: Add tests for:**
- Color slot get/set
- Parent-child inheritance (`_has_*` flags)
- `build_godot_theme()` generates valid theme
- Font size/spacing/radius getters

- [ ] **Step 3: Run tests**

- [ ] **Step 4: Commit**

```bash
git add tests/unit/core/test_ui_flow_theme.gd
git commit -m "test: add theme inheritance, color slots, and build_godot_theme tests"
```

---

### Task 11: Add Tests for UIFlowToast Component

**Files:**
- create: `tests/unit/components/test_ui_flow_toast.gd`

- [ ] **Step 1: Create test file**

```gdscript
## Tests for UIFlowToast — notification system.
extends GdUnitTestSuite

var _toast: UIFlowToast


func before_test() -> void:
    _toast = UIFlowToast.new()
    add_child(_toast)
    await get_tree().process_frame


func after_test() -> void:
    _toast.queue_free()
    _toast = null


## Test: show_toast creates a toast item
func test_show_toast() -> void:
    _toast.show_toast("Test message", "info", 1.0)
    assert_that(_toast.get_child_count()).is_greater_than(0)


## Test: dismiss removes toast
func test_dismiss() -> void:
    _toast.show_toast("Test", "info", 10.0)
    var item := _toast.get_child(0)
    _toast.dismiss(item)
    # Item should be queued for removal
    assert_that(_toast.get_child_count()).is_equal(0)


## Test: dismiss_all clears all toasts
func test_dismiss_all() -> void:
    _toast.show_toast("A", "info", 10.0)
    _toast.show_toast("B", "success", 10.0)
    _toast.dismiss_all()
    assert_that(_toast.get_child_count()).is_equal(0)
```

- [ ] **Step 2: Run tests**

- [ ] **Step 3: Commit**

```bash
git add tests/unit/components/test_ui_flow_toast.gd
git commit -m "test: add UIFlowToast tests for show, dismiss, dismiss_all"
```

---

### Task 12: Add Tests for UIFlowContextMenu

**Files:**
- create: `tests/unit/components/test_ui_flow_context_menu.gd`

- [ ] **Step 1: Create test file**

```gdscript
## Tests for UIFlowContextMenu — right-click context menu.
extends GdUnitTestSuite


## Test: add_item creates button
func test_add_item() -> void:
    var menu := UIFlowContextMenu.new()
    add_child(menu)
    menu.add_item("Test", func(): pass)
    await get_tree().process_frame
    # Menu should have a VBox with a Button
    assert_that(menu._items).has_size(1)
    menu.queue_free()


## Test: add_separator
func test_add_separator() -> void:
    var menu := UIFlowContextMenu.new()
    add_child(menu)
    menu.add_item("A", func(): pass)
    menu.add_separator()
    menu.add_item("B", func(): pass)
    assert_that(menu._items).has_size(3)
    menu.queue_free()


## Test: close emits closed signal
func test_close_signal() -> void:
    var menu := UIFlowContextMenu.new()
    add_child(menu)
    var fired := [false]
    menu.closed.connect(func(): fired[0] = true)
    menu.close()
    assert_that(fired[0]).is_true()
```

- [ ] **Step 2: Run tests**

- [ ] **Step 3: Commit**

```bash
git add tests/unit/components/test_ui_flow_context_menu.gd
git commit -m "test: add UIFlowContextMenu tests for items, separator, close"
```

---

### Task 13: Add Tests for UIFlowGuard

**Files:**
- create: `tests/unit/core/test_ui_flow_guard.gd`

- [ ] **Step 1: Create test file**

```gdscript
## Tests for UIFlowGuard — navigation guard system.
extends GdUnitTestSuite

var _guard


func before_test() -> void:
    var guard_script = preload("res://addons/ui_flow/core/ui_flow_guard.gd")
    _guard = guard_script.new()


func after_test() -> void:
    _guard = null


## Test: no guards allows navigation
func test_no_guards_allows() -> void:
    var result := _guard.can_navigate(null, null, null)
    assert_that(result).is_true()


## Test: global guard blocks
func test_global_guard_blocks() -> void:
    _guard.add_guard(func(from, to, data): return false)
    var result := _guard.can_navigate(null, null, null)
    assert_that(result).is_false()


## Test: global guard allows
func test_global_guard_allows() -> void:
    _guard.add_guard(func(from, to, data): return true)
    var result := _guard.can_navigate(null, null, null)
    assert_that(result).is_true()


## Test: remove_guard
func test_remove_guard() -> void:
    var g := func(from, to, data): return false
    _guard.add_guard(g)
    _guard.remove_guard(g)
    var result := _guard.can_navigate(null, null, null)
    assert_that(result).is_true()


## Test: clear removes all
func test_clear() -> void:
    _guard.add_guard(func(from, to, data): return false)
    _guard.add_guard(func(from, to, data): return false)
    _guard.clear()
    var result := _guard.can_navigate(null, null, null)
    assert_that(result).is_true()
```

- [ ] **Step 2: Run tests**

- [ ] **Step 3: Commit**

```bash
git add tests/unit/core/test_ui_flow_guard.gd
git commit -m "test: add UIFlowGuard tests for allow, block, remove, clear"
```

---

## Phase 4: Documentation

### Task 14: Expand Getting Started Guide

**Files:**
- modify: `addons/ui_flow/docs/getting_started.md`

- [ ] **Step 1: Read current guide**

- [ ] **Step 2: Add sections:**
- Installation (plugin setup, autoload registration)
- Quick Start (minimal 2-page navigation example)
- Page Lifecycle (6 hooks explained with diagram)
- Data Binding (bind_signal, bind_signal_t, bind_visible with examples)
- Navigation (push/pop/replace, guards, modal vs non-modal)
- Transitions (built-in effects, custom effects, presets)
- Components (Toast, Confirm, Alert, Tooltip, ContextMenu, DataGrid)
- Theming (UIFlowTheme, color slots, inheritance)
- Tips & Best Practices

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/docs/getting_started.md
git commit -m "docs: expand getting started guide with all UIFlow features"
```

---

### Task 15: Create API Reference

**Files:**
- create: `addons/ui_flow/docs/api_reference.md`

- [ ] **Step 1: Create reference document**

Document every public class with:
- Class name and purpose
- Properties (with types and defaults)
- Methods (with signatures and descriptions)
- Signals
- Usage example

Classes to document:
- UIFlow (autoload API)
- UIFlowPage (lifecycle, configuration)
- UIFlowDataStore (reactive data pattern)
- UIFlowBindUtils (all binding functions)
- UIFlowNavigator (push/pop/replace)
- UIFlowTheme (color slots, inheritance)
- UIFlowTransitionEffect (base + all effects)
- UIFlowToast / UIFlowConfirmDialog / UIFlowAlertDialog
- UIFlowTooltip / UIFlowHoverHint
- UIFlowContextMenu
- UIFlowDataGrid
- UIFlowDataStyle
- UIFlowVirtualList
- UIFlowWorldUI
- UIFlowItemSlot / UIFlowInventoryGrid
- UIFlowDragDrop / UIFlowDropTarget
- UIFlowEventBus
- UIFlowUtils

- [ ] **Step 2: Commit**

```bash
git add addons/ui_flow/docs/api_reference.md
git commit -m "docs: create comprehensive API reference for all UIFlow classes"
```

---

## Phase 5: Editor Tooling

### Task 16: Enhance Editor Dock with Page Visualization

**Files:**
- modify: `addons/ui_flow/editor/flow_dock.gd`

**Problem:** Editor dock only shows a file list. Should show page relationships and navigation flow.

- [ ] **Step 1: Read current flow_dock.gd**

- [ ] **Step 2: Add page relationship detection**

Scan all page scripts for `UIFlow.push()` calls to build a navigation graph:

```gdscript
func _build_navigation_graph() -> Dictionary:
    var graph: Dictionary = {}  # page_class -> [pushed_classes]
    # Scan all .gd files in UIScene/ and examples/
    # Find UIFlow.push(ClassName) calls
    # Build adjacency list
    return graph
```

- [ ] **Step 3: Display navigation flow in Tree**

Enhance the Tree control to show:
- Page name
- Pages it pushes (children)
- Whether it's modal
- Transition type (if configured)

- [ ] **Step 4: Add click-to-open**

When clicking a page in the dock, open its .gd and .tscn files.

- [ ] **Step 5: Commit**

```bash
git add addons/ui_flow/editor/flow_dock.gd
git commit -m "feat: editor dock shows page navigation graph and relationships"
```

---

### Task 17: Add Transition Preview Button

**Files:**
- modify: `addons/ui_flow/editor/flow_dock.gd`

- [ ] **Step 1: Add preview functionality**

When a page with transitions is selected in the dock, show a "Preview Transition" button that:
1. Creates a temporary preview node
2. Plays the enter transition
3. Shows the result in a popup

- [ ] **Step 2: Use existing preset system**

Load the generated .tres presets from `addons/ui_flow/transitions/presets/` and display them in a dropdown for quick preview.

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/editor/flow_dock.gd
git commit -m "feat: transition preview button in editor dock"
```

---

### Task 18: Add Inspector Plugin for UIFlowPage

**Files:**
- create: `addons/ui_flow/editor/page_inspector_plugin.gd`
- modify: `addons/ui_flow/plugin.gd` (register inspector plugin)

- [ ] **Step 1: Create inspector plugin**

Show a custom inspector section for UIFlowPage nodes with:
- Lifecycle status (which callbacks are implemented)
- Transition configuration (dropdown of presets)
- Input action list (from UIInputActionNode children)
- Quick links to scene and script files

- [ ] **Step 2: Register in plugin.gd**

```gdscript
func _enter_tree() -> void:
    # ... existing code
    var inspector_plugin = preload("res://addons/ui_flow/editor/page_inspector_plugin.gd").new()
    add_inspector_plugin(inspector_plugin)
```

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/editor/page_inspector_plugin.gd addons/ui_flow/plugin.gd
git commit -m "feat: inspector plugin for UIFlowPage — lifecycle, transitions, actions"
```

---

## Task 19: Final Verification

- [ ] **Step 1: Run full test suite**

```bash
F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd --add res://tests
```

Expected: All tests pass.

- [ ] **Step 2: Compile check**

```bash
F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --path . --headless --quit
```

Expected: No errors.

- [ ] **Step 3: Verify examples still work**

Run the main scene and verify:
- Free Demo: all 6 pages work
- Survivors Demo: full game loop works
- Code panel (F1) shows correct snippets
- Language toggle works

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "chore: UIFlow plugin improvement complete — bugs fixed, systems completed, tests added, docs expanded, editor enhanced"
```
