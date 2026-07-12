# 导航与传参

## 基础 API

```gdscript
# 压入新页面
UIFlow.push(PageClass, {"level": 3})

# 压入已实例化的 Control（注意：不要传入 PageClass.new()）
var instance := preload("res://UIScene/SomePage.tscn").instantiate()
UIFlow.push_instance(instance, {"score": 100})

# 返回上一页
UIFlow.pop()

# 替换当前页
UIFlow.replace(PageClass, {"chapter": 2})

# 清空栈并压入
UIFlow.clear_and_push(PageClass)

# 返回指定页面（关闭其上的所有页面）
UIFlow.pop_to(PageClass)
```

## 数据传递

数据通过 `Dictionary` 传递，在 `_on_created` / `_on_opened` 中读取：

```gdscript
func _on_opened(data: Dictionary) -> void:
    var level: int = data.get("level", 1)
    _setup_level(level)
```

## 返回值

被关闭的页面可以通过 `UIFlow.pop_result(result)` 向上一页返回数据：

```gdscript
# SettingsPage.gd
func _on_apply() -> void:
    UIFlow.pop_result({"fullscreen": fullscreen_check.button_pressed})
```

接收页通过 `_on_shown` 重新获取焦点，或通过事件总线订阅结果。

## 模态页面

在页面检查器勾选 **Is Modal**，该页面会阻止下方页面接收输入，并自动添加透明输入拦截层。

```gdscript
func _on_opened(_data: Dictionary) -> void:
    # 模态页默认点击返回/ESC 会关闭，可在配置中关闭该行为
    pass
```

## 防止重复导航

`UIFlowNavigator` 在动画期间会上锁，连续调用会进入队列按顺序执行，避免重叠。

## 返回拦截

重写 `_on_back()` 可拦截返回：

```gdscript
func _on_back() -> bool:
    if _has_unsaved_changes:
        UIFlowUI.Confirm.show("有未保存的更改，确定退出？", _confirm_exit)
        return true  # 已处理，不再 pop
    return false
```
