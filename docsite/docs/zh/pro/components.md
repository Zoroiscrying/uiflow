# Pro 组件

!!! tip "Pro 功能"
    以下组件仅在 **UIFlow Pro** 中提供。

UIFlow Pro 扩展了 Free 的组件集，增加了面向大数据和游戏专用的控件。

## UIFlowProDataGrid

更强大的数据表格，支持排序、筛选、列拖拽、分页和行选中回调。

```gdscript
var grid := $ProDataGrid
grid.set_columns([
    {"name": "name", "title": "道具", "sortable": true, "width": 180},
    {"name": "rarity", "title": "稀有度", "filterable": true, "width": 100},
    {"name": "price", "title": "价格", "sortable": true, "align": "right"}
])
grid.set_data(shop_items)
grid.row_selected.connect(_on_item_selected)
```

## UIFlowProVirtualList

针对超大列表优化的虚拟列表，支持可变行高和选中状态保持。

```gdscript
virtual_list.bind(
    quest_list,
    preload("res://UIScene/QuestRow.tscn"),
    _setup_quest,
    {"estimated_height": 64}
)
```

## UIFlowProInventoryGrid

专为背包和装备界面设计：

- 拖拽 rearrangement。
- 按道具类型 / 稀有度高亮格子。
- 堆叠数量显示。
- 装备分类筛选（武器、护甲、消耗品）。

```gdscript
inventory_grid.set_inventory(player_inventory)
inventory_grid.slot_clicked.connect(_on_slot_clicked)
```

## UIFlowProTreeView

层级数据展示，适合技能树、科技树或文件浏览器：

```gdscript
tree_view.set_root({
    "name": "技能",
    "children": [
        {"name": "战斗", "children": [{"name": "剑术精通"}, {"name": "双持"}]},
        {"name": "魔法", "children": [{"name": "火球术"}, {"name": "冰盾"}]}
    ]
})
```

## UIFlowProChartView

用于属性、进度或分析的轻量图表：

- 折线图、柱状图、饼图。
- 通过 `Dictionary` 或 `Array` 驱动。
- 主题感知配色。

## UIFlowProWorldUI

跟随 3D 节点的世界空间 UI：

- 名称板、血条、浮动伤害数字。
- 广告牌或锁定旋转模式。
- 自动池化和清理。

## UIFlowProRichTextPanel

富文本渲染组件，支持标记、内联图标和可点击链接，封装为可复用页面组件。

## 从 Free 组件迁移

部分 Pro 组件与 Free 组件同名（例如 `UIFlowDataGrid`）。Pro 版本通常暴露 Free API 的超集，升级时通常只需替换场景/脚本引用。
