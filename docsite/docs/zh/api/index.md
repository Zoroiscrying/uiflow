# API 参考

本页面列出 UIFlow Free 中最常用的类与函数。详细实现请直接查看 `addons/ui_flow/` 源码。

## UIFlow（autoload）

```gdscript
UIFlow.push(page_class: GDScript, data := {}, page_theme := null)
UIFlow.push_instance(instance: Control, data := {})
UIFlow.push_async(page_class: GDScript, data := {}, page_theme := null)
UIFlow.push_async_with_loading(page_class: GDScript, data := {}, page_theme := null, loading_page_class: GDScript = null)
UIFlow.pop()
UIFlow.replace(page_class: GDScript, data := {}, page_theme := null)
UIFlow.pop_to(page_class: GDScript)
UIFlow.clear_and_push(page_class: GDScript, data := {})
UIFlow.pop_result(result: Variant)

# 子系统
UIFlow.Navigator
UIFlow.SceneResolver
UIFlow.Animator
UIFlow.EventBus
UIFlow.DataStore
UIFlow.ThemeHelper
UIFlow.Config

# 主题（优先使用原生 Godot Theme；UIFlowTheme 为 legacy 兼容）
UIFlow.set_theme(theme: Variant)          # Theme 或 UIFlowTheme
UIFlow.apply_godot_theme(theme: Theme)
UIFlow.get_godot_theme() -> Theme
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

_on_back() -> bool          # 返回 true 表示已拦截

bind_property(source, src_prop, target, tgt_prop)
bind_signal(sig: Signal, callback: Callable)
```

## UIFlowUI（autoload）

```gdscript
UIFlowUI.Toast.show_toast(message, type_name, duration)
UIFlowUI.Confirm.show_confirm(title, message, on_confirm, on_cancel, options)
UIFlowUI.Alert.show_alert(title, message, on_close, options)

# 替换默认实现
UIFlowUI.set_custom_toast(custom_toast)
UIFlowUI.set_custom_confirm(custom_confirm)
UIFlowUI.set_custom_alert(custom_alert)
```

## 配置资源

- `UIFlowConfig`：全局配置。
- `UIFlowTheme`：主题资源。
- `UIFlowRoute`：路由映射资源。

## 完整源码

所有 API 的完整签名与实现位于 `addons/ui_flow/core/`、`addons/ui_flow/components/` 和 `addons/ui_flow/resources/`。
