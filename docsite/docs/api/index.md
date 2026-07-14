# API Reference

This page lists the most commonly used classes and functions in UIFlow Free. For full implementations, see the source code in `addons/ui_flow/`.

## UIFlow (autoload)

```gdscript
UIFlow.push(page_class: GDScript, data := {})
UIFlow.push_instance(instance: Control, data := {})
UIFlow.pop()
UIFlow.replace(page_class: GDScript, data := {})
UIFlow.pop_to(page_class: GDScript)
UIFlow.clear_and_push(page_class: GDScript, data := {})
UIFlow.pop_result(result: Variant)

# Subsystems
UIFlow.Navigator
UIFlow.SceneResolver
UIFlow.Animator
UIFlow.EventBus
UIFlow.DataStore
UIFlow.ThemeHelper
UIFlow.Config
```

## UIFlowPage

```gdscript
_on_created(data: Dictionary)
_on_opened(data: Dictionary)
_on_after_opened()
_on_hidden()
_on_shown()
_on_before_closed()
_on_closed()
_on_destroyed()

_on_back() -> bool          # return true to intercept

bind_property(source, src_prop, target, tgt_prop)
bind_signal(sig: Signal, callback: Callable)
```

## UIFlowUI (autoload)

```gdscript
UIFlowUI.Toast.show_toast(message, type_name, duration)
UIFlowUI.Confirm.show_confirm(title, message, on_confirm, on_cancel, options)
UIFlowUI.Alert.show_alert(title, message, on_close, options)

# Replace default implementations
UIFlowUI.set_custom_toast(custom_toast)
UIFlowUI.set_custom_confirm(custom_confirm)
UIFlowUI.set_custom_alert(custom_alert)
```

## Configuration Resources

- `UIFlowConfig`: global configuration.
- `UIFlowTheme`: theme resource.
- `UIFlowRoute`: route mapping resource.

## Full Source

Complete signatures and implementations are in `addons/ui_flow/core/`, `addons/ui_flow/components/`, and `addons/ui_flow/resources/`.
