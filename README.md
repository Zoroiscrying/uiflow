# UI Flow — Godot UI Workflow Framework

A complete UI workflow framework for Godot 4.x — navigation, data binding, transitions, and components.

## Features

- **Stack-based Navigation** — Push/pop/replace pages with lifecycle callbacks
- **Class-based Routing** — Reference pages by `class_name`, no strings needed
- **Transition System** — Built-in presets (fade, slide, scale) + custom transitions; preview enter/exit directly in the editor
- **Data Binding** — Reactive Resource + Signal pattern for data-driven UI
- **Event Bus** — Decoupled cross-system communication via native Signals
- **Components** — Toast, Confirm Dialog, Alert Dialog, Inventory Grid (Pro)
- **Dual Language** — GDScript core with C# wrapper bridge
- **Editor Tools (Pro)** — Pro Hub with Theme Editor, Page Viewer, Navigation Flow Graph, and UIFlowDebugger

## Quick Start

### 1. Enable the Plugin

1. Copy `addons/ui_flow/` to your project
2. Project Settings → Plugins → Enable "UI Flow"

### 2. Create a Page

```gdscript
# home_page.gd
class_name HomePage extends UIFlowPage

func _on_opened(data: Variant = null) -> void:
    super._on_opened(data)
    print("Home page opened!")

func _on_back() -> void:
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

## Pro Editor Tools

When `addons/ui_flow_pro/` is enabled, the **UIFlow Pro Hub** dock provides:

- **Page Viewer** — thumbnails of every `UIFlowPage` scene; right-click to open scene/script or re-render
- **Navigation Flow Graph** — auto-scan static `push` / `replace` / `push_instance` calls and visualize page connections
- **Theme Editor** — visual color palette editor with presets, live preview, and undo/redo
- **UIFlowDebugger** — runtime navigation stack, page pool, event bus, and binding/subscription leak diagnostics

## Documentation

See `addons/ui_flow/docs/` for detailed documentation.

## License

MIT License — see [LICENSE](LICENSE) for details.
