# Pro 组件

!!! tip "Pro 功能"
    以下组件仅在 **UIFlow Pro** 中提供。

UIFlow Pro 扩展了 Free 的组件集，增加了面向大数据和游戏专用的控件。

## UIFlowProDataGrid

更强大的数据表格，支持排序、筛选、列宽调整、分页、单元格/行编辑和行条纹。

```gdscript
var grid := $ProDataGrid
grid.setup([
    {"name": "name", "title": "道具", "sortable": true, "filterable": true, "editable": true, "width": 180},
    {"name": "rarity", "title": "稀有度", "filterable": true, "width": 100},
    {"name": "price", "title": "价格", "sortable": true, "align": "right"}
], preload("res://UIScene/ItemRow.tscn"))
grid.page_size = 20
grid.set_data(shop_items)
grid.cell_edited.connect(_on_cell_edited)
grid.row_edited.connect(_on_row_edited)
```

### 功能

- **排序** — 点击可排序列头。
- **筛选** — 全局 `set_filter()` 加每列筛选输入框。
- **分页** — `page_size` 配合上一页/下一页按钮。
- **列宽调整** — 拖拽列头右边缘。
- **单元格编辑** — 双击可编辑单元格。
- **行编辑** — 双击行打开编辑面板。
- **条纹** — 通过 `show_stripes` 和 `stripe_color` 设置交替行背景。

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

层级数据展示，适合技能树、科技树或文件浏览器，支持拖拽排序、多选和虚拟滚动。

```gdscript
tree_view.set_root({
    "id": "root",
    "label": "技能",
    "children": [
        {"id": "combat", "label": "战斗", "children": [
            {"id": "sword", "label": "剑术精通"},
            {"id": "dual", "label": "双持"}
        ]},
        {"id": "magic", "label": "魔法", "children": [
            {"id": "fireball", "label": "火球术"},
            {"id": "ice", "label": "冰盾"}
        ]}
    ]
})
```

### 功能

- **拖拽排序** — 拖到节点上作为子节点；拖到上/下边缘作为兄弟节点前/后插入。
- **多选** — Ctrl+点击切换，Shift+点击范围选择。
- **键盘导航** — 上/下移动选择，左/右折叠/展开，Enter 激活。
- **虚拟滚动** — 大数据量时只渲染可视行。
- **事件** — `item_moved`、`selection_changed`、`item_activated`。

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
