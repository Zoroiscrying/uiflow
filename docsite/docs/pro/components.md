# Pro Components

!!! tip "Pro Feature"
    These components are only available in **UIFlow Pro**.

UIFlow Pro extends the Free component set with data-heavy and game-specific widgets.

## UIFlowProDataGrid

A more capable data grid with sorting, filtering, column reordering, pagination, and row selection callbacks.

```gdscript
var grid := $ProDataGrid
grid.set_columns([
    {"name": "name", "title": "Item", "sortable": true, "width": 180},
    {"name": "rarity", "title": "Rarity", "filterable": true, "width": 100},
    {"name": "price", "title": "Price", "sortable": true, "align": "right"}
])
grid.set_data(shop_items)
grid.row_selected.connect(_on_item_selected)
```

## UIFlowProVirtualList

Virtual list optimized for very large datasets with variable row heights and selection persistence.

```gdscript
virtual_list.bind(
    quest_list,
    preload("res://UIScene/QuestRow.tscn"),
    _setup_quest,
    {"estimated_height": 64}
)
```

## UIFlowProInventoryGrid

Purpose-built for inventories and equipment screens:

- Drag-and-drop rearrangement.
- Slot highlighting by item type / rarity.
- Stack size rendering.
- Equipment category filters (weapon, armor, consumable).

```gdscript
inventory_grid.set_inventory(player_inventory)
inventory_grid.slot_clicked.connect(_on_slot_clicked)
```

## UIFlowProTreeView

Hierarchical data display for skill trees, tech trees, or file browsers:

```gdscript
tree_view.set_root({
    "name": "Skills",
    "children": [
        {"name": "Combat", "children": [{"name": "Sword Mastery"}, {"name": "Dual Wield"}]},
        {"name": "Magic", "children": [{"name": "Fireball"}, {"name": "Ice Shield"}]}
    ]
})
```

## UIFlowProChartView

Basic charting for stats, progression, or analytics:

- Line, bar, and pie charts.
- Data-driven via `Dictionary` or `Array`.
- Theme-aware colors.

## UIFlowProWorldUI

World-space UI components that follow 3D nodes:

- Nameplates, health bars, and floating damage numbers.
- Billboard or locked-rotation modes.
- Automatic pooling and cleanup.

## UIFlowProRichTextPanel

Rich text rendering with markup, inline icons, and clickable links, wrapped as a reusable page component.

## Migration from Free Components

Some Pro components share names with Free components (e.g., `UIFlowDataGrid`). Pro versions usually expose a superset of the Free API, so upgrading is often a matter of swapping the scene/script reference.
