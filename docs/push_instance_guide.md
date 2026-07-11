## Correct Usage of `push_instance`

`push_instance` is used to **push an already-instantiated Control into the navigation stack**, bypassing `SceneResolver`'s `.tscn` lookup and `PackedScene.instantiate()` process.

### Recommended Usage

#### 1. Pre-modify after instantiating from a `.tscn` (most common)

```gdscript
var scene = preload("res://UIScene/MyPage.tscn")
var instance = scene.instantiate()
instance.get_node("Title").text = "Dynamic Title"  # Modify before pushing
instance.get_node("Icon").texture = some_texture
UIFlow.push_instance(instance, data)
```

**Why use `push_instance`**: You need to modify existing child nodes in the `.tscn` before pushing it onto the stack. You could also do this in `_on_created()`, but `push_instance` is more flexible.

#### 2. Object pool reuse (performance optimization)

```gdscript
var pooled_instance = _scene_resolver.acquire_pooled(MyPage)
if pooled_instance != null:
    pooled_instance.reset_state()  # Reset state
    UIFlow.push_instance(pooled_instance, data)
else:
    UIFlow.push(MyPage, data)  # Pool empty, use normal path
```

#### 3. Existing node needs navigation management

```gdscript
# Take a node from elsewhere and let UIFlow manage it
var existing_node = get_node("SomeUI")
get_parent().remove_child(existing_node)
UIFlow.push_instance(existing_node, data)
```

### Not Recommended

#### ❌ Creating an empty node with `new()` (no `.tscn`)

```gdscript
# Don't do this: new() creates an empty node with no children
var page = MyPage.new()  # Empty node! No buttons, no labels
UIFlow.push_instance(page, data)
```

**Reason**: Godot's core is the visual scene editor. Building a UI tree manually in code is tedious and hard to maintain. All pages should have a `.tscn` scene file.

### Key Differences

| | `push(page_class)` | `push_instance(instance)` |
|---|---|---|
| **Instantiation** | `SceneResolver` finds `.tscn` → `PackedScene.instantiate()` | Uses the passed instance directly |
| **Children** | Yes (from .tscn) | Depends on the passed instance |
| **Lifecycle** | Calls `_on_created()` | Calls `_on_created()` |
| **Use case** | Standard page navigation (99%) | Pre-modify .tscn, reuse, or existing node |

### Summary

- **`push`** = "Load the .tscn scene by class name and push it onto the stack" (use this 99% of the time)
- **`push_instance`** = "Push an existing instance onto the stack" (use when you need to pre-modify, reuse, or manage an existing node)
