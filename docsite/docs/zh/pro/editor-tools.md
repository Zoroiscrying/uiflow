# Pro 编辑器工具

!!! tip "Pro 功能"
    以下编辑器工具仅在 **UIFlow Pro** 中提供。

UIFlow Pro 在 Godot 编辑器中添加了多个面板和检查器，加速 UI 工作流。

## 主题管理器

在编辑器内管理 UIFlow 使用的原生 Godot Theme 资源。

- 选择任意 `.tres` Theme 资源，或在 UIFlow 内置预设之间切换（dark、light、ocean、forest、high contrast、warm）。
- 在实时组件画廊上预览主题效果。
- 一键应用主题到 UIFlow 自动加载并设为项目默认主题。
- 在 Godot 内置 Theme 检查器中打开选中主题进行完整编辑。
- 将旧版 `UIFlowTheme` 资源导入为原生 Godot Theme。

启用 UIFlow Pro 插件后，**UIFlow Pro** 坞会自动出现。选择其中的 **Theme Manager** 标签页。

<!-- TODO: UI 定稿后替换为新的主题管理器截图 -->

## 流程坞 / 流程图

可视化页面导航流程图。

- 所有已发现页面显示为节点。
- push/pop 关系显示为边。
- 从图中直接跳转到页面场景或脚本。

适合审查复杂 UI 流程是否存在不可达页面或循环导航。

![流程图](/assets/screenshots/flow_graph.png)

## 页面查看器

列出所有在已配置场景目录中发现的页面。

- 按类名或场景路径筛选。
- 一键打开场景或脚本。
- 查看哪些页面被流程图引用。

## 性能分析器

轻量 UI 性能分析工具：

- 跟踪导航耗时。
- 监控对象池命中/未命中率。
- 查看事件总线订阅数量。

## 启用 Pro 编辑器工具

在 **项目设置 → 插件** 中启用 **UIFlow Pro** 后，面板会自动出现。你可以像其他 Godot 面板一样重新排列它们。

!!! tip
    Pro 编辑器工具只在 Godot 编辑器中、且 Pro 插件启用时工作。导出构建中会被剔除。
