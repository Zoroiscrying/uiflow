# UIFlow

UIFlow is a UI workflow framework for **Godot 4.6+**. It provides stack-based page navigation, page lifecycle management, transition animations, data binding, an event bus, and a set of reusable UI components.

This documentation covers the **UIFlow Free** plugin only. Pro plugin features are not documented here.

## Key Features

- **Stack navigation**: `push` / `pop` / `replace`, with modal support and back interception.
- **Lifecycle hooks**: `_on_created` → `_on_opened` → `_on_after_opened` → `_on_hidden` / `_on_shown` → `_on_closed` / `_on_destroyed`.
- **Transitions**: built-in Fade, Slide, Scale, Timeline, and more. Configure enter / exit per page.
- **Data binding**: `bind_property`, `bind_signal`, `bind_list`. Bindings are automatically cleaned up when a page closes.
- **Event bus**: pub/sub, sticky values, one-shot subscriptions, and auto-cleanup by subscriber.
- **Async / Timeline**: combine animations and async logic with `await`.
- **Reusable components**: Toast, Confirm / Alert dialogs, DataGrid, VirtualList, Tooltip, and more.

## Use Cases

- RPG / ARPG / card / simulation games that need a complex UI stack.
- Mid-size projects that want each screen managed as an independent page.
- Teams that prefer GDScript with optional C# wrappers.

## Quick Start

```bash
godot --path . --scene res://addons/ui_flow/examples/main.tscn
```

Or follow [Installation](getting-started/installation.md) to integrate the plugin into your own project.
