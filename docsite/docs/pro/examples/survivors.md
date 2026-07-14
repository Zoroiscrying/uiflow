# Survivors ARPG Demo

!!! tip "Pro Feature"
    The Survivors demo is only available in **UIFlow Pro**.

The Survivors demo is a full ARPG-style example built with UIFlow Pro. It demonstrates how to use Pro components and transitions in a real game loop.

## How to Run

Open the Pro examples folder and run the main survivors scene:

```bash
godot --path . --scene res://addons/ui_flow_pro/examples/survivors/main.tscn
```

## Included Pages

- **Main HUD**: health bar, experience bar, minimap, wave timer.
- **Level Up Page**: skill selection with `UIFlowProTreeView`.
- **Equipment Page**: inventory and equipment slots using `UIFlowProInventoryGrid`.
- **Shop Page**: buy/sell items with `UIFlowProDataGrid`.
- **Pause Page**: settings, resume, and quit with confirmation dialog.
- **Wave Summary Page**: stats and rewards after each wave.

## Pro Features Used

- **Pro transitions**: advanced enter/exit effects for menus.
- **Pro components**: `UIFlowProInventoryGrid`, `UIFlowProDataGrid`, `UIFlowProTreeView`.
- **Runtime debugger**: inspect stack and pool state while playing.
- **Theme Editor**: the demo uses a custom Pro theme.

## Learning Points

- HUD pages are pushed with no transition so gameplay is not interrupted.
- Modal pages (shop, level up, pause) block input to the game world.
- The event bus coordinates wave state, player stats, and UI updates.

![Survivors demo screenshot](../assets/screenshots/survivors_demo.png)
