# 页面过渡

UIFlow 支持在页面资源上配置 **Enter Effect** 和 **Exit Effect**，也可以使用代码手动播放。

## 配置方式

在页面场景的根节点 `UIFlowPage` 资源检查器中：

- **Enter Effect**：页面进入栈时播放。
- **Exit Effect**：页面离开栈时播放。
- 勾选 **Exit Reverse Play Enter** 时，exit 会使用 enter effect 的反向时间线。

![页面检查器中的过渡配置](/assets/screenshots/page_transition_config.png)

## 内置效果

| 效果 | 说明 |
|---|---|
| `UIFlowFadeEffect` | 淡入淡出 |
| `UIFlowSlideEffect` | 滑入滑出，可指定方向 |
| `UIFlowScaleEffect` | 缩放，可配合自定义 curve 实现 punch 弹性 |
| `UIFlowTimelineEffect` | 多段组合效果，支持顺序与并行 |

## 代码手动播放

```gdscript
UIFlow.Animator.tween(self, UIFlowTweenProp.SCALE, Vector2.ONE * 1.2, 0.2) \
    .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
```

## 反向播放

当 **Exit Reverse Play Enter** 启用时，exit 会：

- 复用 enter 的全部 step。
- 将每段动画的 from / to 交换。
- 逆序整体时间线。

适合 enter 做了复杂的 Scale / Fade 组合，而 exit 希望做“倒放”的情况。
