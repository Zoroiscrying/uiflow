# UIFlow API Reference

## UIFlow (Autoload)

Main singleton. Access via `UIFlow`.

### Navigation

| Method | Signature | Description |
|--------|-----------|-------------|
| `push` | `(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null) -> Control` | Push page onto stack |
| `push_instance` | `(instance: Control, data: Variant = null) -> Control` | Push pre-instantiated page |
| `pop` | `() -> void` | Pop top page |
| `replace` | `(page_class: GDScript, data: Variant = null, page_theme: UIFlowTheme = null) -> Control` | Replace top page |
| `pop_to_root` | `() -> void` | Remove all pages except first |
| `current_page` | `() -> GDScript` | Get current top page class |
| `stack_depth` | `() -> int` | Get stack depth |
| `navigation_path` | `() -> Array[StringName]` | Get full path |
| `get_page` | `(page_class: GDScript) -> Control` | Find page in stack |
| `has_page` | `(page_class: GDScript) -> bool` | Check if page exists |

### Guards

| Method | Signature | Description |
|--------|-----------|-------------|
| `add_guard` | `(guard: Callable) -> void` | Add global guard |
| `remove_guard` | `(guard: Callable) -> void` | Remove global guard |
| `add_page_guard` | `(page_class: GDScript, guard: Callable) -> void` | Add page-specific guard |
| `remove_page_guard` | `(page_class: GDScript, guard: Callable) -> void` | Remove page guard |
| `clear_guards` | `() -> void` | Clear all guards |

### Binding

| Method | Signature | Description |
|--------|-----------|-------------|
| `bind_signal` | `(node, prop, signal) -> UIFlowBinding` | Signal → property |
| `bind_signal_t` | `(node, prop, signal, transform) -> UIFlowBinding` | Signal → transform → property |
| `bind_visible` | `(node, signal, predicate) -> UIFlowBinding` | Signal → predicate → visibility |
| `bind_format` | `(node, prop, signal, format) -> UIFlowBinding` | Signal → format string |
| `bind_slider` | `(slider, signal, setter) -> UIFlowBinding` | Two-way slider binding |
| `bind_list` | `(container, signal, template, binder)` | Array → UI template list |

### Animation

| Method | Signature | Description |
|--------|-----------|-------------|
| `animate` | `(node, prop, from, to, duration, ease, trans) -> Tween` | Tween property |
| `animate_raw` | `(node, prop_path, from, to, duration, ease, trans) -> Tween` | Tween by string path |
| `sequencer` | `() -> UIFlowSequencer` | Create animation sequencer |
| `anim_hover_enter` | `(node) -> Tween` | Hover scale up |
| `anim_hover_exit` | `(node) -> Tween` | Hover scale reset |
| `anim_press_down` | `(node) -> Tween` | Press effect |
| `anim_press_up` | `(node) -> Tween` | Release effect |
| `anim_shake` | `(node, intensity) -> Tween` | Shake animation |
| `anim_pulse` | `(node) -> Tween` | Pulse animation |
| `anim_fade_in` | `(node, duration) -> Tween` | Fade in |
| `anim_fade_out` | `(node, duration) -> Tween` | Fade out |
| `anim_stagger_fade` | `(parent) -> UIFlowSequencer` | Staggered fade-in |

### Theme

| Method | Signature | Description |
|--------|-----------|-------------|
| `apply_theme` | `(theme: UIFlowTheme) -> void` | Apply custom theme |
| `apply_builtin_theme` | `(name: String) -> void` | Apply "dark" or "light" |
| `get_theme` | `() -> UIFlowTheme` | Get current theme |
| `get_color` | `(slot) -> Color` | Get theme color |
| `set_color` | `(slot, color) -> void` | Set theme color |

### Signals

| Signal | Parameters | Description |
|--------|------------|-------------|
| `page_opened` | `page_class: GDScript` | Page _on_opened completed |
| `page_closed` | `page_class: GDScript` | Page _on_closed completed |

---

## UIFlowPage

Base class for all UI pages. Extend this.

### Properties (@export)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `is_modal` | `bool` | `false` | Block input to pages below |
| `enter_transition` | `UIFlowTransitionRef` | `null` | Transition on push |
| `exit_transition` | `UIFlowTransitionRef` | `null` | Transition on pop |
| `default_focus_path` | `NodePath` | `""` | Node to focus on open |

### Lifecycle Methods

| Method | When Called |
|--------|------------|
| `_on_created(data)` | Page instantiated |
| `_on_opened(data)` | Page pushed onto stack |
| `_on_hidden()` | Another page pushed on top |
| `_on_shown()` | Page above popped |
| `_on_closed()` | Page removed from stack |
| `_on_destroyed()` | Page about to be freed |

### Input Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `get_action` | `(name) -> UIInputActionNode` | Get action by name |
| `get_all_actions` | `() -> Array` | Get all actions |
| `get_enabled_actions` | `() -> Array` | Get enabled actions |
| `set_action_enabled` | `(name, enabled) -> void` | Enable/disable action |

---

## UIFlowDataStore

Base class for reactive data stores. Extend and define signals + setter-emits.

```gdscript
class_name PlayerData extends UIFlowDataStore

signal health_changed(value: float)

var health: float = 100.0:
    set(v): health = clampf(v, 0, max_health); health_changed.emit(health)
```

---

## UIFlowBindUtils

Static utility for data binding.

### UIFlowBinding

| Method | Description |
|--------|-------------|
| `unbind()` | Disconnect binding |

### Functions

| Function | Description |
|----------|-------------|
| `bind_signal(node, prop, sig)` | Signal → property |
| `bind_signal_t(node, prop, sig, transform)` | Signal → transform → property |
| `bind_visible(node, sig, predicate)` | Signal → predicate → visibility |
| `bind_format(node, prop, sig, format)` | Signal → format string |
| `bind_multi(node, prop, signals, formatter)` | Multiple signals → formatter |
| `bind_slider(slider, sig, setter)` | Two-way slider |

---

## UIFlowTheme

Hierarchical theme with inheritance.

### Color Slots

| Slot | Description |
|------|-------------|
| `PRIMARY` | Primary brand color |
| `SECONDARY` | Secondary color |
| `ACCENT` | Accent/highlight color |
| `ERROR` | Error state |
| `WARNING` | Warning state |
| `SUCCESS` | Success state |
| `INFO` | Information |
| `BACKGROUND` | Page background |
| `SURFACE` | Card/panel surface |
| `ON_PRIMARY` | Text on primary |
| `ON_SECONDARY` | Text on secondary |
| `ON_SURFACE` | Text on surface |

### Methods

| Method | Description |
|--------|-------------|
| `get_color(slot)` | Get color value |
| `set_color(slot, color)` | Set color value |
| `build_godot_theme()` | Generate Godot Theme resource |

---

## UIFlowTransitionEffect

Base Resource for transition effects.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `starts_hidden` | `bool` | Node starts invisible |
| `from_current` | `bool` | Animate from current value |
| `duration` | `float` | Animation duration |
| `ease_type` | `Tween.EaseType` | Easing function |
| `trans_type` | `Tween.TransitionType` | Transition curve |
| `delay` | `float` | Delay before start |

### Built-in Effects

| Class | Description |
|-------|-------------|
| `UIFlowFadeEffect` | Opacity animation |
| `UIFlowSlideEffect` | Position slide (LEFT/RIGHT/UP/DOWN) |
| `UIFlowScaleEffect` | Scale animation |
| `UIFlowCompositeEffect` | Multiple effects in parallel |
| `UIFlowSequencedEffect` | Multiple effects in sequence |

---

## UIFlowUI (Autoload)

Component instances. Access via `UIFlowUI`.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Toast` | `UIFlowToast` | Toast notification manager |
| `Confirm` | `UIFlowConfirmDialog` | Confirm dialog |
| `Alert` | `UIFlowAlertDialog` | Alert dialog |

---

## UIFlowToast

| Method | Signature | Description |
|--------|-----------|-------------|
| `show_toast` | `(message, type, duration)` | Show toast notification |
| `dismiss` | `(item)` | Dismiss specific toast |
| `dismiss_all` | `()` | Dismiss all toasts |

Built-in types: `"info"`, `"success"`, `"warning"`, `"error"`

---

## UIFlowConfirmDialog

| Method | Signature | Description |
|--------|-----------|-------------|
| `show_confirm` | `(title, message, on_confirm, on_cancel)` | Show confirm dialog |

---

## UIFlowAlertDialog

| Method | Signature | Description |
|--------|-----------|-------------|
| `show_alert` | `(title, message, on_close)` | Show alert dialog |

---

## UIFlowTooltip

| Method | Signature | Description |
|--------|-----------|-------------|
| `attach` (static) | `(control, text) -> UIFlowTooltip` | Attach tooltip to control |

---

## UIFlowHoverHint

| Method | Signature | Description |
|--------|-----------|-------------|
| `attach` (static) | `(control, text, bbcode) -> UIFlowHoverHint` | Attach hover hint |

---

## UIFlowContextMenu

| Method | Signature | Description |
|--------|-----------|-------------|
| `add_item` | `(label, callback) -> UIFlowContextMenu` | Add menu item (chainable) |
| `add_separator` | `() -> UIFlowContextMenu` | Add separator |
| `add_submenu` | `(label) -> UIFlowContextMenu` | Add submenu (returns submenu) |
| `show_at` | `(position)` | Show at screen position |
| `close` | `()` | Close menu |

### Signals

| Signal | Description |
|--------|-------------|
| `item_selected(item_name)` | Item clicked |
| `closed` | Menu closed |

---

## UIFlowDataGrid

| Method | Signature | Description |
|--------|-----------|-------------|
| `add_column` | `(title, width, sortable)` | Add column definition |
| `set_data` | `(data: Array)` | Set row data (Array of Arrays) |
| `get_data` | `() -> Array` | Get current data |
| `sort_by` | `(column, ascending)` | Sort by column |
| `get_selected` | `() -> Array` | Get selected row |

### Signals

| Signal | Description |
|--------|-------------|
| `row_selected(index, data)` | Row selected |
| `row_clicked(index, data)` | Row clicked |
| `column_sorted(column, ascending)` | Column sorted |

---

## UIFlowDataStyle

Data-driven conditional styling.

| Method | Signature | Description |
|--------|-----------|-------------|
| `add_rule` | `(condition: Callable, style: Dictionary)` | Add styling rule |
| `bind_signal` | `(sig: Signal)` | Bind to signal for evaluation |

Style keys: `"modulate"`, `"modulate_a"`, `"visible"`, `"pulse"`, `"shake"`, `"scale"`

---

## UIFlowVirtualList

Virtual scrolling for large lists.

| Method | Signature | Description |
|--------|-----------|-------------|
| `set_total_count` | `(count)` | Set total item count |
| `refresh` | `()` | Refresh display |

### Signals

| Signal | Description |
|--------|-------------|
| `on_update(node, index)` | Request update for visible item |

---

## UIFlowWorldUI

Projects UI to follow a 3D node.

| Property | Type | Description |
|----------|------|-------------|
| `target` | `Node3D` | 3D node to follow |
| `offset` | `Vector2` | Screen offset |
| `world_offset` | `Vector3` | 3D offset (e.g., above head) |
| `clamp_to_screen` | `bool` | Clamp to viewport |
| `smooth_speed` | `float` | Follow smoothing |

---

## UIFlowItemSlot

Equipment/inventory slot with drag-drop.

| Signal | Description |
|--------|-------------|
| `item_dropped(item, from_index)` | Item dropped into slot |
| `item_dragged(item, slot_index)` | Item dragged from slot |

| Property | Type | Description |
|----------|------|-------------|
| `slot_index` | `int` | Slot index |
| `accept_type` | `StringName` | Type filter |
| `is_equip_slot` | `bool` | Is equipment slot |

---

## UIFlowInventoryGrid

Grid of ItemSlots bound to InventoryData.

| Method | Signature | Description |
|--------|-----------|-------------|
| `setup` | `(data: InventoryData)` | Initialize with inventory data |

---

## UIFlowEventBus

Base class for decoupled event communication.

| Method | Signature | Description |
|--------|-----------|-------------|
| `register` | `(event_name) -> Signal` | Register dynamic event |
| `emit_event` | `(event_name, data)` | Emit dynamic event |

---

## UIFlowUtils

Static utilities.

| Method | Description |
|--------|-------------|
| `for_each_child(node, callback)` | Iterate children |
| `for_each_descendant(node, callback)` | Iterate descendants |
| `find_child_by_type(node, type)` | Find first child by type |
| `find_children_by_type(node, type)` | Find all children by type |
| `find_child_by_name(node, name)` | Find child by name |
| `reserve_children(parent, count, template, on_update)` | Ensure exact child count |
| `reserve_children_factory(parent, count, factory, on_update)` | Same with factory |
| `clear_children(parent)` | Remove all children |

---

## UIFlowSequencer

Sequential animation player.

| Method | Signature | Description |
|--------|-----------|-------------|
| `add` | `(node, prop, from, to, duration, ease, trans)` | Add step (chainable) |
| `delay` | `(seconds)` | Set delay on last step |
| `play` | `()` | Start playback |

### Signals

| Signal | Description |
|--------|-------------|
| `finished` | Playback complete |
