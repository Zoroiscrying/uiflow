# Demo Hub

The Demo Hub is the main entry example for UIFlow Free. It demonstrates core navigation and page transitions.

## How to Run

```bash
godot --path . --scene res://addons/ui_flow/examples/main.tscn
```

This scene is also the project's default main scene.

## Contents

- Main menu page
- Settings page (demonstrates back interception and saving config)
- Data binding example page
- Event bus example page
- Timeline / Async animation example page

![Demo Hub main screen](/assets/screenshots/demo_hub_main.png)

## Learning Points

- Every page is a `UIFlowPage` subclass, with scenes in `res://UIScene/` or the plugin's internal examples folder.
- Back buttons and ESC both trigger `_on_back()`.
- Page transitions use the default transition configuration.
