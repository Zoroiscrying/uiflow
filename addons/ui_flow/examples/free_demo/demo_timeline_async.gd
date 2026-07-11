## Timeline & Async Loading Demo — showcases UIFlowTimelineEffect and push_async_with_loading.
class_name UIFlowDemoTimelineAsync extends UIFlowPage

const TimelineAsyncTargetPage = preload("res://addons/ui_flow/examples/free_demo/timeline_async_target_page.gd")
const AsyncTargetPage = preload("res://addons/ui_flow/examples/free_demo/async_target_page.gd")
const AsyncLoadingPage = preload("res://addons/ui_flow/examples/free_demo/async_loading_page.gd")

@onready var _back_button: Button = $Panel/VBox/BackButton
@onready var _status_label: Label = $Panel/VBox/StatusLabel


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())
	$Panel/VBox/TimelineScalePunchBtn.pressed.connect(_on_timeline_scale_punch)
	$Panel/VBox/AsyncPushBtn.pressed.connect(_on_async_push)
	$Panel/VBox/PreWarmBtn.pressed.connect(_on_pre_warm)


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus($Panel/VBox/TimelineScalePunchBtn)


func _on_timeline_scale_punch() -> void:
	UIFlow.push(TimelineAsyncTargetPage, {
		"title": "Timeline: Scale → Scale (Punch)",
	})


func _on_async_push() -> void:
	_status_label.text = ""
	await UIFlow.push_async_with_loading(AsyncTargetPage, {
		"title": "Async Loaded",
	}, null, AsyncLoadingPage)


func _on_pre_warm() -> void:
	_status_label.text = "Pre-warming..."
	await UIFlow.load_scenes_async([AsyncTargetPage])
	_status_label.text = "Pre-warmed! Try async push again — it should be instant."


func _on_back() -> void:
	UIFlow.pop()
