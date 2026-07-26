# Gamepad UI

UIFlow ships gamepad-first UI support in the Free core: **directional focus navigation** and an analog-stick **virtual cursor** (CommonUI `CommonAnalogCursor` equivalent).

## Directional Focus Navigation

Godot 4.6 moves focus on directional input using explicit `focus_neighbor_*` assignments or a viewport-wide geometry guess — but the guess knows nothing about your UI structure and can wander into covered pages or unrelated overlays. `UIFlow.Focus` intercepts directional input before the engine and makes navigation authoritative for the top page:

- `ui_left` / `ui_right` / `ui_up` / `ui_down` (arrow keys, d-pad, left stick) move focus between focusable controls **of the top page only** — focus can never leak into pages below.
- Explicit `focus_neighbor_*` assignments on a control always win over the automatic geometry search.
- Disabled controls and invisible controls are skipped automatically.
- Controls that use arrow keys internally (LineEdit, TextEdit, ItemList, Tree, sliders, tabs, scroll containers) keep their keys; focus owners outside the top page (e.g. overlay dialogs) are handled by the engine as usual.

```gdscript
# Move focus programmatically (usually not needed — input is handled for you):
UIFlow.Focus.move_focus(Vector2.RIGHT)
```

### Configuration

| `UIFlowConfig` property | Default | Effect |
|---|---|---|
| `enable_directional_focus` | `true` | Master switch for directional focus navigation. |
| `focus_wrap_enabled` | `false` | `true`: focus wraps to the opposite edge; `false`: focus is trapped at edges. |
| `auto_focus_on_push` | `true` | Pages grab their `default_focus_path` control when opened. |
| `restore_focus_on_pop` | `true` | When a page is shown again, focus returns to the control that had it before the page was hidden. |

### Focus Memory

Every page remembers which of its controls had focus when it was hidden (push, replace, bring-to-front). When the page is shown again, focus is restored to that control — falling back to `default_focus_path` when nothing was remembered. Memory entries are dropped when a page is closed.

## Virtual Cursor

`UIFlow.Cursor` is an analog-stick driven cursor for mouse-oriented UIs (inventories, tooltips, drag & drop). It is disabled by default:

```gdscript
UIFlow.Cursor.enable()    # show cursor, hide OS mouse
UIFlow.Cursor.disable()   # hide cursor, restore OS mouse
UIFlow.Cursor.is_enabled()
UIFlow.Cursor.get_cursor_position()
```

Behavior while enabled:

- The **left stick** moves the cursor (d-pad and arrow keys stay on focus navigation).
- The OS mouse is hidden and warped to the cursor, so hover states and tooltips keep working (disable with `warp_os_cursor = false`, e.g. in headless tests).
- `ui_accept` clicks at the cursor position; `UIFlow.Cursor.click()` does the same from code.

Tunable exports: `cursor_speed`, `acceleration`, `deadzone`, `joy_device`, `accept_action`, `cursor_texture` (a simple arrow is drawn when unset).

## Device-aware input prompts

`UIFlow.InputDevice` tracks whether the player last used **keyboard/mouse** or a **gamepad**, and emits `device_changed` when that flips.

```gdscript
UIFlow.InputDevice.is_gamepad()
UIFlow.InputDevice.device_changed.connect(func(kind): refresh_prompts())
```

`UIFlowInputPrompt.make_semantic(&"interact", "Open chest")` builds a chip with a Kenney (CC0) glyph for the active device (Xbox A vs keyboard E, etc.). Textures live under `addons/ui_flow/assets/input_prompts/`.

The 3D world `MainHUD` uses these chips and refreshes when the device changes.

## Demo

A standalone demo scene showcases focus movement, wrap/trap, disabled-button skipping, focus memory, and the virtual cursor:

```
res://addons/ui_flow/examples/scenes/gamepad_demo.tscn
```

It is also reachable from the demo hub ("Gamepad Demo" button).
