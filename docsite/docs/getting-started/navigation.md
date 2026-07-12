# Navigation and Data Passing

## Basic API

```gdscript
# Push a new page
UIFlow.push(PageClass, {"level": 3})

# Push an already instantiated Control (do not pass PageClass.new())
var instance := preload("res://UIScene/SomePage.tscn").instantiate()
UIFlow.push_instance(instance, {"score": 100})

# Go back
UIFlow.pop()

# Replace the current page
UIFlow.replace(PageClass, {"chapter": 2})

# Clear the stack and push a new page
UIFlow.clear_and_push(PageClass)

# Pop to a specific page (closes all pages above it)
UIFlow.pop_to(PageClass)
```

## Passing Data

Data is passed as a `Dictionary` and read in `_on_created` / `_on_opened`:

```gdscript
func _on_opened(data: Dictionary) -> void:
    var level: int = data.get("level", 1)
    _setup_level(level)
```

## Returning Results

A closed page can return data to the previous page using `UIFlow.pop_result(result)`:

```gdscript
# SettingsPage.gd
func _on_apply() -> void:
    UIFlow.pop_result({"fullscreen": fullscreen_check.button_pressed})
```

The receiving page regains focus through `_on_shown`, or you can subscribe to a result event on the event bus.

## Modal Pages

Enable **Is Modal** in the page inspector to block input to pages below and automatically add a transparent input blocker.

```gdscript
func _on_opened(_data: Dictionary) -> void:
    # Modal pages close on back/ESC by default; disable in config if needed
    pass
```

## Preventing Duplicate Navigation

`UIFlowNavigator` locks during animations. Consecutive calls are queued and executed in order to avoid overlap.

## Intercepting Back

Override `_on_back()` to intercept the back action:

```gdscript
func _on_back() -> bool:
    if _has_unsaved_changes:
        UIFlowUI.Confirm.show("Unsaved changes. Exit anyway?", _confirm_exit)
        return true  # handled, do not pop
    return false
```
