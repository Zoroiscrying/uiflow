# Timeline and Async

UIFlow supports combining multiple animations / waits into a **Timeline**, and integrating them with `await`.

## Timeline Effect

`UIFlowTimelineEffect` consists of multiple `UIFlowEffect` steps. You can configure:

- **Effects**: the effect array for each step.
- **Step Delays**: delay before each step starts.
- **Step Wait for Completion**: whether to wait for the step to finish before the next one.

## Two-stage Scale Punch Example

![Timeline configuration](/assets/screenshots/timeline_scale_config.png)

```gdscript
# Configuration:
# Step 0: UIFlowScaleEffect, duration 0.15, from 0.0 to 0.5, punch-out curve
# Step 1: UIFlowScaleEffect, duration 0.15, from 0.5 to 1.0, punch-out curve
```

This makes the page scale quickly to 0.5, then bounce to full size for a punch-elastic feel.

## Async Flow

You can `await` UIFlow animations directly inside a page:

```gdscript
func _play_open_sequence() -> void:
    await UIFlow.Animator.tween(self, UIFlowTweenProp.MODULATE, Color.WHITE, 0.2).finished
    await UIFlow.Animator.tween(self, UIFlowTweenProp.SCALE, Vector2.ONE, 0.3).finished
    _enable_input()
```

## Combining with Navigation

```gdscript
func _on_start() -> void:
    await UIFlow.Animator.tween(self, UIFlowTweenProp.OPACITY, 0.0, 0.2).finished
    UIFlow.push(GamePage)
```

## Recommendations

- Prefer `UIFlowTimelineEffect` resources for complex enter / exit animations.
- Use inline `await` for quick one-off animations.
