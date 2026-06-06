# Getting Started with UI Flow

## Installation

1. Copy the `addons/ui_flow/` folder into your project's `addons/` directory.
2. Open Godot, go to **Project → Project Settings → Plugins**.
3. Enable the **UI Flow** plugin.

This automatically registers the `UIFlow` autoload singleton.

## Project Configuration

In **Project Settings → General → ui_flow**, you can configure:

| Setting | Default | Description |
|---------|---------|-------------|
| `ui_flow/scene_directory` | `res://UIScene/` | Default directory for page scenes |

## Creating Your First Page

### 1. Create a Script

Create a new GDScript file and extend `UIFlowPage`:

```gdscript
# my_page.gd
class_name MyPage extends UIFlowPage

func _on_enter(data: Dictionary = {}) -> void:
    print("Page entered with data: ", data)

func _on_exit() -> void:
    print("Page exited")

func _on_pause() -> void:
    print("Page paused (another page pushed on top)")

func _on_resume() -> void:
    print("Page resumed (page above popped)")
```

### 2. Create a Scene

Create a new scene with a `Control` node as root. Attach `my_page.gd` to it.

### 3. Place the Scene

Save the scene as `MyPage.tscn` in the configured scene directory (default: `res://UIScene/`).

**Important**: The scene filename must exactly match the `class_name`. If your class is `MyPage`, the file must be `MyPage.tscn`.

### 4. Navigate

```gdscript
# In your main scene or any script:
func _ready() -> void:
    UIFlow.push(MyPage)
```

## Navigation

### Push a Page

```gdscript
UIFlow.push(SettingsPage)                         # Simple push
UIFlow.push(ShopPage, {"npc_id": 123})            # Push with data
UIFlow.push(SettingsPage, {}, UIFlowTransitionType.Type.SLIDE_LEFT)  # Custom transition
```

### Pop a Page

```gdscript
UIFlow.pop()                                      # Pop with default transition
UIFlow.pop(UIFlowTransitionType.Type.FADE)        # Pop with custom transition
```

### Replace a Page

```gdscript
UIFlow.replace(GameOverPage)                      # Replace without increasing stack depth
```

### Pop to Root

```gdscript
UIFlow.pop_to_root()                              # Remove all pages except the first
```

### Check State

```gdscript
var current = UIFlow.current_page()               # Get current page class
var depth = UIFlow.stack_depth()                  # Get stack depth
var path = UIFlow.navigation_path()               # Get full path as Array[StringName]
```

## Transitions

### Built-in Presets

| Type | Description |
|------|-------------|
| `UIFlowTransitionType.Type.NONE` | Instant, no animation |
| `UIFlowTransitionType.Type.FADE` | Fade in/out |
| `UIFlowTransitionType.Type.SLIDE_LEFT` | Slide from right |
| `UIFlowTransitionType.Type.SLIDE_RIGHT` | Slide from left |
| `UIFlowTransitionType.Type.SLIDE_UP` | Slide from bottom |
| `UIFlowTransitionType.Type.SLIDE_DOWN` | Slide from top |
| `UIFlowTransitionType.Type.SCALE` | Scale from zero |

### Custom Transition Parameters

```gdscript
var transition = UIFlow.create_transition(
    UIFlowTransitionType.Type.FADE,
    0.5,                          # Duration in seconds
    Tween.EASE_OUT,               # Ease type
    Tween.TRANS_CUBIC             # Transition type
)
UIFlow.push(SettingsPage, {}, transition)
```

### Set Default Transition

```gdscript
UIFlow.set_default_transition(UIFlowTransitionType.Type.FADE, 0.3)
```

## Custom Scene Paths

If your scene doesn't follow the naming convention:

```gdscript
UIFlow.register_scene(SettingsPage, preload("res://custom/path/MySettings.tscn"))
```
