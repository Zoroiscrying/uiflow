# Pro Editor Tools

!!! tip "Pro Feature"
    These editor tools are only available in **UIFlow Pro**.

UIFlow Pro adds several docks and inspectors to the Godot editor to speed up UI workflow.

## Theme Editor

Edit `UIFlowTheme` resources visually without hand-writing property dictionaries.

- Preview colors, fonts, spacing, and radius values.
- Switch between dark and light previews.
- Export a theme variant as a new `.tres` file.

Open it from **Project → Tools → UIFlow Pro → Theme Editor** when the plugin is enabled.

## Flow Dock / Flow Graph

A visual graph of your page navigation flow.

- See all discovered pages as nodes.
- View push/pop relationships as edges.
- Jump to a page scene or script from the graph.

This is useful for reviewing whether a complex UI flow has unreachable pages or circular navigation.

## Page Viewer

A dock that lists all pages found in the configured scene directories.

- Filter by class name or scene path.
- Open the scene or script with one click.
- See which pages are referenced by the Flow Graph.

## Profiler

A lightweight profiler for UI performance:

- Track navigation timing.
- Monitor object pool hit/miss rates.
- See event bus subscription counts.

## Enabling Pro Editor Tools

After enabling the **UIFlow Pro** plugin in **Project Settings → Plugins**, the docks appear automatically. You can rearrange them like any other Godot dock.

!!! tip
    Pro editor tools only work inside the Godot editor with the Pro plugin enabled. They are stripped from exported builds.
