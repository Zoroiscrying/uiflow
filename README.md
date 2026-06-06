# UI Flow — Godot UI Workflow Framework

A complete UI workflow framework for Godot 4.x — navigation, data binding, transitions, and components.

## Features

- **Stack-based Navigation** — Push/pop/replace pages with lifecycle callbacks
- **Class-based Routing** — Reference pages by `class_name`, no strings needed
- **Transition System** — Built-in presets (fade, slide, scale) + custom transitions
- **Data Binding** — Reactive Resource + Signal pattern for data-driven UI
- **Event Bus** — Decoupled cross-system communication via native Signals
- **Components** — Toast, Confirm Dialog, Alert Dialog
- **Dual Language** — GDScript (Free) + C# (Pro)

## Quick Start

### 1. Enable the Plugin

1. Copy `addons/ui_flow/` to your project
2. Project Settings → Plugins → Enable "UI Flow"

### 2. Create a Page

```gdscript
# home_page.gd
class_name HomePage extends UIFlowPage

func _on_enter(data: Dictionary = {}) -> void:
    print("Home page entered!")

func _on_back_pressed() -> void:
    UIFlow.push(SettingsPage)
```

### 3. Place the Scene

Place `HomePage.tscn` in `res://UIScene/` (configurable in Project Settings).

### 4. Navigate

```gdscript
# In your main scene
func _ready() -> void:
    UIFlow.push(HomePage)
```

## Documentation

See `addons/ui_flow/docs/` for detailed documentation.

## License

MIT License — see [LICENSE](LICENSE) for details.
