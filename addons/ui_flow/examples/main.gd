## Main entry point — UIFlow Free Demo.
## Showcases core UIFlow features: navigation, data binding, transitions, components, themes.
extends Control

const DemoHub = preload("res://addons/ui_flow/examples/free_demo/demo_hub.gd")

var _code_overlay: UIFlowCodeOverlay

# Free Demo page → API snippets
const _PAGE_SNIPPETS: Dictionary = {
	"UIFlowDemoHub": [
		{"title": "UIFlow.push() — Push page", "code": "UIFlow.push(DemoNavigation)"},
		{"title": "set_default_focus — Default focus", "code": "UIFlow.set_default_focus(\n    _buttons.get_child(0) as Button)"},
		{"title": "_on_back — Back handler", "code": "func _on_back():\n    pass  # Root page — no action"},
	],
	"UIFlowDemoNavigation": [
		{"title": "UIFlow.push() — Push page", "code": "UIFlow.push(get_script())  # Push same class"},
		{"title": "UIFlow.pop() — Pop page", "code": "_back_button.pressed.connect(\n    func(): UIFlow.pop())"},
		{"title": "UIFlow.stack_depth() — Stack depth", "code": "_stack_label.text = \"Stack depth: %d\"\n    % UIFlow.stack_depth()"},
	],
	"UIFlowDemoDataBinding": [
		{"title": "bind_signal_t — Signal + transform", "code": "UIFlow.bind_signal_t(\n    _score_label, \"text\",\n    emitter.value_changed,\n    func(v): return \"Score: %d\" % v)"},
		{"title": "bind_signal — Property binding", "code": "UIFlow.bind_signal(\n    _health_bar, \"value\",\n    emitter.health_changed)"},
	],
	"UIFlowDemoTransitions": [
		{"title": "UIFlow.push + enter_effect", "code": "UIFlow.push(TransitionDemoPage, {\n    \"transition_name\": \"Fade\",\n    \"enter_preset\": UIFlowTransitionType.Type.FADE,\n    \"enter_duration\": 0.3,\n})"},
		{"title": "exit_effect — Exit animation", "code": "# Configure in .tscn or code:\nexit_effect = UIFlowFadeEffect.new()"},
	],
	"UIFlowDemoComponents": [
		{"title": "UIFlowUI.Toast — Notification", "code": "UIFlowUI.Toast.show_toast(\n    \"Hello!\", \"info\", 3.0)"},
		{"title": "UIFlowUI.Confirm — Confirm dialog", "code": "UIFlowUI.Confirm.show_confirm(\n    \"Confirm\", \"Are you sure?\",\n    func(): print(\"OK\"),\n    func(): print(\"Cancel\"))"},
		{"title": "HoverHint overlay", "code": "UIFlowHoverHint.attach(\n    $Button, \"Rich hint\", true)\n# Popup draws on CanvasLayer 100"},
	],
	"UIFlowDemoTheme": [
		{"title": "apply_godot_theme — Switch native Theme", "code": "UIFlow.apply_godot_theme(\n    preload(\"res://addons/ui_flow/themes/godot/dark.tres\"))\nUIFlow.apply_godot_theme(\n    preload(\"res://addons/ui_flow/themes/godot/light.tres\"))"},
	],
	"UIFlowDemoTimelineAsync": [
		{"title": "UIFlowTimelineEffect — Scene configured", "code": "# TimelineAsyncTargetPage has enter_effect set in its .tscn\nUIFlow.push(TimelineAsyncTargetPage, {\n    \"title\": \"Timeline: Scale → Scale (Punch)\",\n})"},
		{"title": "push_async_with_loading", "code": "await UIFlow.push_async_with_loading(\n    AsyncTargetPage, {}, null, LoadingPage)"},
	],
	"UIFlowDemoWorkflow": [
		{"title": "PageOpener", "code": "var opener := UIFlowPageOpener.new()\nopener.page_script = ShopPage\n$Button.add_child(opener)"},
		{"title": "ChildrenSwitcher multi-target", "code": "$Switcher.set_state(1)\n# One state updates many NodePaths"},
		{"title": "ChildPool", "code": "$Pool.ensure_count(6, func(slot, i):\n    slot.setup(skills[i]))"},
	],
	"GamepadDemoPage": [
		{"title": "Virtual cursor", "code": "UIFlow.Cursor.enable()\n# Stick moves cursor; ui_accept clicks under it"},
		{"title": "Directional focus", "code": "# D-Pad / arrows move focus (FocusNavigator)\n# Stick is consumed while Cursor is ON"},
	],
	"TransitionDemoPage": [
		{"title": "enter_effect — Entry animation", "code": "var effect := UIFlowFadeEffect.new()\neffect.duration = 0.3\nenter_effect = effect"},
	],
}


func _ready() -> void:
	UIFlow.pop_to_root()
	await _setup_code_overlay()
	UIFlow.push(DemoHub)


func _setup_code_overlay() -> void:
	# Reuse an existing overlay if the demo was re-entered without freeing /root.
	var existing := get_tree().root.get_node_or_null("CodeOverlay")
	if existing is UIFlowCodeOverlay:
		_code_overlay = existing as UIFlowCodeOverlay
	else:
		_code_overlay = UIFlowCodeOverlay.new()
		_code_overlay.name = "CodeOverlay"
		get_tree().root.add_child.call_deferred(_code_overlay)
		if not _code_overlay.is_node_ready():
			await _code_overlay.ready
		else:
			await get_tree().process_frame
	if not UIFlow.page_opened.is_connected(_on_page_opened):
		UIFlow.page_opened.connect(_on_page_opened)


func _on_page_opened(page_class: GDScript) -> void:
	if page_class == null or _code_overlay == null:
		return
	var class_name_str: String = page_class.get_global_name()
	var snippets: Array = _PAGE_SNIPPETS.get(class_name_str, [])
	_code_overlay.show_snippets(class_name_str, snippets)
