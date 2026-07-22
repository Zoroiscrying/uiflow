# Pro Components

!!! tip "Pro Feature"
    These components are only available in **UIFlow Pro**.

UIFlow Pro extends the Free component set with data-heavy and game-specific widgets.

## UIFlowProDataGrid

A more capable data grid with sorting, filtering, column resizing, pagination, cell/row editing, and row striping.

```gdscript
var grid := $ProDataGrid
grid.setup([
    {"name": "name", "title": "Item", "sortable": true, "filterable": true, "editable": true, "width": 180},
    {"name": "rarity", "title": "Rarity", "filterable": true, "width": 100},
    {"name": "price", "title": "Price", "sortable": true, "align": "right"}
], preload("res://UIScene/ItemRow.tscn"))
grid.page_size = 20
grid.set_data(shop_items)
grid.cell_edited.connect(_on_cell_edited)
grid.row_edited.connect(_on_row_edited)
```

### Features

- **Sorting** — click sortable column headers.
- **Filtering** — global `set_filter()` plus per-column filter inputs.
- **Pagination** — `page_size` with previous/next controls.
- **Column resize** — drag the right edge of a column header.
- **Cell editing** — double-click an editable cell.
- **Row editing** — double-click a row to open an edit panel.
- **Striping** — alternating row background via `show_stripes` and `stripe_color`.

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

Hierarchical data display for skill trees, tech trees, or file browsers, with drag-and-drop reordering, multi-select, and virtual scrolling.

```gdscript
tree_view.set_root({
    "id": "root",
    "label": "Skills",
    "children": [
        {"id": "combat", "label": "Combat", "children": [
            {"id": "sword", "label": "Sword Mastery"},
            {"id": "dual", "label": "Dual Wield"}
        ]},
        {"id": "magic", "label": "Magic", "children": [
            {"id": "fireball", "label": "Fireball"},
            {"id": "ice", "label": "Ice Shield"}
        ]}
    ]
})
```

### Features

- **Drag-and-drop reordering** — drop onto a node to insert as child; drop near top/bottom edge to insert as sibling before/after.
- **Multi-select** — Ctrl+click toggles, Shift+click range-selects.
- **Keyboard navigation** — Up/Down moves selection, Left/Right collapses/expands, Enter activates.
- **Virtual scrolling** — only visible rows are rendered for large trees.
- **Events** — `item_moved`, `selection_changed`, `item_activated`.

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
