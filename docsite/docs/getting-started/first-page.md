# Your First Page

UIFlow pages extend `UIFlowPage` and are associated with a `.tscn` scene file.

## Create the Page Script

```gdscript
# main_menu_page.gd
extends UIFlowPage
class_name MainMenuPage

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton

func _on_opened(data: Dictionary) -> void:
    start_button.pressed.connect(_on_start)
    settings_button.pressed.connect(_on_settings)

func _on_closed() -> void:
    start_button.pressed.disconnect(_on_start)
    settings_button.pressed.disconnect(_on_settings)

func _on_start() -> void:
    UIFlow.push(GamePage)

func _on_settings() -> void:
    UIFlow.push(SettingsPage)
```

## Create the Scene

1. Create a `Control` node named `MainMenuPage`.
2. Attach the script to it.
3. Save it as `res://UIScene/MainMenuPage.tscn`.
4. Make sure the root node's `class_name` matches the file name: `MainMenuPage`.

## Launch the Page

From any entry script:

```gdscript
func _ready() -> void:
    UIFlow.push(MainMenuPage)
```

UIFlow uses `UIFlowSceneResolver` to automatically find `MainMenuPage.tscn` and instantiate it.

## Lifecycle Hooks

A page triggers the following hooks from creation to destruction:

1. `_on_created(data)` — instance created, not yet added to the tree.
2. `_on_opened(data)` — added to the tree, before enter animation.
3. `_on_after_opened()` — enter animation finished, focus applied.
4. `_on_hidden()` — covered by a new page.
5. `_on_shown()` — the page above was closed, this page is visible again.
6. `_on_before_closed()` — before exit animation.
7. `_on_closed()` — removed from the stack, after exit animation.
8. `_on_destroyed()` — node about to be freed.

Connecting and disconnecting signals inside `_on_opened` / `_on_closed` is a common pattern.
