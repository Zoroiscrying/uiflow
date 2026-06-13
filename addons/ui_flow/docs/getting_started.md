# Getting Started with UIFlow

## Installation

1. Copy the `addons/ui_flow/` folder into your project's `addons/` directory.
2. Open Godot, go to **Project → Project Settings → Plugins**.
3. Enable the **UI Flow** plugin.

This automatically registers two autoloads:
- `UIFlow` — Core navigation, binding, animation API
- `UIFlowUI` — Component instances (Toast, Confirm, Alert)

## Project Configuration

### Scene Directory

UIFlow resolves page classes to scenes by convention: `{scene_dir}/{ClassName}.tscn`

Default: `res://UIScene/`

Configure in **Project Settings → General → ui_flow/scene_directory**.

### Config Resource (Optional)

Create `res://ui_flow_config.tres` (UIFlowConfig resource) to customize:

| Property | Default | Description |
|----------|---------|-------------|
| `scene_directory` | `res://UIScene/` | Where page scenes live |
| `back_action` | `ui_cancel` | Input action for back/cancel |
| `default_transition` | `FADE` | Default page transition |
| `default_transition_duration` | `0.3` | Transition duration in seconds |
| `auto_focus_on_push` | `true` | Focus default node on page open |
| `restore_focus_on_pop` | `true` | Restore focus when page closes |

## Creating Your First Page

### 1. Create a Script

```gdscript
# MyPage.gd
class_name MyPage extends UIFlowPage

func _on_opened(_data: Variant = null) -> void:
    print("Page opened")

func _on_closed() -> void:
    print("Page closed")
```

### 2. Create a Scene

Create a scene with a `Control` root node. Attach `MyPage.gd`. Save as `res://UIScene/MyPage.tscn`.

**Important**: Filename must match `class_name` exactly.

### 3. Navigate

```gdscript
UIFlow.push(MyPage)
```

## Page Lifecycle

Pages have 6 lifecycle hooks, called in this order:

| Hook | When | Use Case |
|------|------|----------|
| `_on_created(data)` | Page instantiated (once) | One-time setup |
| `_on_opened(data)` | Page pushed onto stack | Setup bindings, initialize UI |
| `_on_hidden()` | Another page pushed on top | Pause timers, save state |
| `_on_shown()` | Page above popped | Resume timers, refresh data |
| `_on_closed()` | Page removed from stack | Unbind signals, cleanup |
| `_on_destroyed()` | Page about to be freed | Final cleanup |

```gdscript
class_name GameHUD extends UIFlowPage

var _bindings: Array = []

func _on_opened(_data: Variant = null) -> void:
    _bindings.append(
        UIFlow.bind_signal($HealthBar, "value", player_stats.health_changed)
    )

func _on_hidden() -> void:
    # Timer paused — game still runs but HUD doesn't update
    pass

func _on_shown() -> void:
    # Timer resumed
    pass

func _on_closed() -> void:
    for b in _bindings:
        b.unbind()
    _bindings.clear()
```

## Navigation

### Push / Pop / Replace

```gdscript
UIFlow.push(ShopPage, {"items": shop_items})   # Push with data
UIFlow.pop()                                    # Pop top page
UIFlow.replace(GameOverPage, {"score": 100})   # Replace without growing stack
UIFlow.pop_to_root()                            # Return to first page
```

### Find Pages in Stack

```gdscript
var hud := UIFlow.get_page(GameHUD)            # Find by class
var exists := UIFlow.has_page(ShopPage)         # Check existence
var depth := UIFlow.stack_depth()               # Stack depth
```

### Navigation Guards

Block navigation conditionally:

```gdscript
# Block shop during combat
UIFlow.add_page_guard(ShopPage, func(from, data):
    if game.in_combat():
        UIFlowUI.Toast.show_toast("Can't shop during combat!", "warning")
        return false
    return true
)

# Global guard — blocks all navigation
UIFlow.add_guard(func(from, to, data):
    return not game.is_loading
)
```

### Modal vs Non-Modal

```gdscript
class_name PauseMenu extends UIFlowPage

func _ready() -> void:
    is_modal = true              # Blocks input to pages below
    process_mode = Node.PROCESS_MODE_ALWAYS  # Works while game is paused

func _on_opened(_data = null) -> void:
    get_tree().paused = true

func _on_closed() -> void:
    get_tree().paused = false
```

## Data Binding

### Signal → Property

```gdscript
# Direct binding: signal value → property
UIFlow.bind_signal($ProgressBar, "value", stats.health_changed)

# Transform binding: signal value → transform → property
UIFlow.bind_signal_t($Label, "text", stats.gold_changed,
    func(v): return "%d G" % v
)

# Visibility binding: signal value → predicate → visible
UIFlow.bind_visible($WaveLabel, stats.wave_active_changed,
    func(active): return active
)

# Format binding: signal value → format string
UIFlow.bind_format($Label, "text", stats.level_changed, "Lv. %s")
```

### Cleanup

Always unbind in `_on_closed`:

```gdscript
var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []

func _on_opened(_data = null) -> void:
    _bindings.append(UIFlow.bind_signal($Bar, "value", signal))

func _on_closed() -> void:
    for b in _bindings:
        b.unbind()
    _bindings.clear()
```

### Reactive Data Store

```gdscript
class_name PlayerStats extends UIFlowDataStore

signal health_changed(value: float)
signal gold_changed(value: int)

var health: float = 100.0:
    set(v): health = clampf(v, 0, max_health); health_changed.emit(health)

var gold: int = 0:
    set(v): gold = maxi(v, 0); gold_changed.emit(gold)
```

## Components

### Toast Notifications

```gdscript
UIFlowUI.Toast.show_toast("Item purchased!", "success", 3.0)
# Types: "info", "success", "warning", "error"
```

### Confirm / Alert Dialogs

```gdscript
UIFlowUI.Confirm.show_confirm("Quit?", "Are you sure?",
    func(): UIFlow.pop_to_root(),   # on_confirm
    func(): pass                     # on_cancel
)

UIFlowUI.Alert.show_alert("Notice", "Something happened.")
```

### Tooltips

```gdscript
UIFlowTooltip.attach($Button, "Click to buy")
```

### Hover Hints (BBCode)

```gdscript
UIFlowHoverHint.attach($Item, "[b]Iron Sword[/b]\nATK +5", true)
```

### Context Menu

```gdscript
var menu := UIFlowContextMenu.new()
menu.add_item("Equip", func(): equip_item())
menu.add_item("Drop", func(): drop_item())
menu.add_separator()
menu.add_submenu("More")
    .add_item("Examine", func(): examine())
menu.show_at(get_global_mouse_position())
```

### Data Grid

```gdscript
var grid := UIFlowDataGrid.new()
grid.add_column("Name", 150, true)    # sortable
grid.add_column("Level", 80, true)
grid.set_data([
    ["Warrior", "5"],
    ["Mage", "3"],
])
grid.row_selected.connect(func(idx, data): print(data))
```

### Data Style (Conditional Styling)

```gdscript
var style := UIFlowDataStyle.new()
style.add_rule(func(v): return v < 25, {"pulse": true})  # Pulse when low
style.add_rule(func(v): return v > 0, {"modulate": Color.GREEN})
style.bind_signal(stats.health_changed)
$HealthBar.add_child(style)
```

## Transitions

### Built-in Effects

| Type | Description |
|------|-------------|
| `FADE` | Opacity animation |
| `SLIDE_LEFT/RIGHT/UP/DOWN` | Position slide |
| `SCALE` | Scale from zero |

### Custom Transition

```gdscript
var effect := UIFlowFadeEffect.new()
effect.duration = 0.5
effect.ease_type = Tween.EASE_OUT

var ref := UIFlowTransitionRef.new()
ref.enter_effect = effect

UIFlow.push(MyPage, null)  # Transition set via @export on page
```

### Per-Page Transitions

Set `enter_transition` and `exit_transition` on the page's `@export` properties in the Inspector, or configure in the `.tscn` scene file.

### Animation Presets

```gdscript
UIFlow.anim_hover_enter($Button)     # Scale up on hover
UIFlow.anim_hover_exit($Button)      # Scale back
UIFlow.anim_press_down($Button)      # Press effect
UIFlow.anim_shake($Label)            # Shake animation
UIFlow.anim_pulse($Icon)             # Pulse animation
UIFlow.anim_fade_in($Panel)          # Fade in
UIFlow.anim_stagger_fade($Container) # Stagger children fade-in
```

### Sequencer

```gdscript
var seq = UIFlowSequencer.new()
seq.add($Panel, UIFlowTweenProp.Prop.MODULATE_A, 0, 1, 0.3)
seq.add($Label, UIFlowTweenProp.Prop.POSITION_Y, 100, 0, 0.4).delay(0.1)
seq.play()
```

## Theming

### Apply Built-in Theme

```gdscript
UIFlow.apply_builtin_theme("dark")   # or "light"
```

### Custom Theme

```gdscript
var theme := UIFlowTheme.new()
theme.set_color(UIFlowTheme.ColorSlot.PRIMARY, Color(0.2, 0.5, 1.0))
theme.set_color(UIFlowTheme.ColorSlot.BACKGROUND, Color(0.1, 0.1, 0.15))
UIFlow.apply_theme(theme)
```

### Theme Inheritance

Themes support parent-child inheritance. Child themes override specific properties; unoverridden properties inherit from parent.

## Event Bus

For decoupled cross-system communication:

```gdscript
# Define
class_name GameEventBus extends UIFlowEventBus
signal enemy_killed(name: String, xp: int)
signal wave_started(wave: int)

# Emit
event_bus.enemy_killed.emit("Goblin", 25)

# Listen
event_bus.enemy_killed.connect(_on_enemy_killed)
```

## Input Actions

Declare input actions as scene nodes on your page:

```
MyPage (UIFlowPage)
├── OpenInventory (UIInputActionNode)  [action=ui_accept, label="Inventory"]
└── Pause (UIInputActionNode)          [action=ui_cancel, label="Pause"]
```

## Tips

1. **Always unbind in `_on_closed`** — prevents signal leaks
2. **Use `is_modal = true`** for dialogs that must block input
3. **Use `process_mode = ALWAYS`** for pages that work while paused
4. **Convention-based scenes** — match `class_name` to filename for auto-resolution
5. **Use `replace()` instead of `push()` + `pop()`** when the old page shouldn't be in the stack
