# Installation

## Get the Plugin

UIFlow Free is distributed as a folder: `addons/ui_flow/`.

1. Copy `addons/ui_flow/` from the release package or source into your Godot project's `addons/` folder.
2. Open **Project Settings → Plugins** and enable **UI Flow**.
3. Enabling the plugin registers two autoloads automatically:
   - `UIFlow`: core navigation, binding, theme, and event bus API.
   - `UIFlowUI`: convenience components such as Toast, Confirm, and Alert.

## Project Settings

You can change the following options under **Project Settings → UI Flow**:

| Setting | Description | Default |
|---|---|---|
| `ui_flow/scene_directory` | Default search directory for page scenes | `res://UIScene/` |
| `ui_flow/max_stack_depth` | Maximum navigation stack depth | `32` |
| `ui_flow/modal_close_on_back` | Whether back/cancel closes modal pages | `true` |
| `ui_flow/default_theme_name` | Default theme name | `dark` |

You can also create a `UIFlowConfig` resource at `res://ui_flow_config.tres` to override more options.

## Recommended Folder Structure

```
res://
├── addons/ui_flow/          # Plugin files
├── UIScene/                 # Your page scenes
│   ├── MainMenuPage.tscn
│   └── SettingsPage.tscn
└── project.godot
```

## Verify Installation

Run the example scene:

```bash
godot --path . --scene res://addons/ui_flow/examples/main.tscn
```

If the Demo Hub appears, the plugin is installed correctly.
