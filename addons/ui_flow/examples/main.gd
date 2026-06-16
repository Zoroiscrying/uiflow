## Main entry point — UIFlow Free Demo.
## Showcases core UIFlow features: navigation, data binding, transitions, components, themes.
extends Control

const DemoHub = preload("res://addons/ui_flow/examples/free_demo/demo_hub.gd")

var _code_panel: UIFlowCodePanel

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
		{"title": "UIFlow.push + enter_transition", "code": "UIFlow.push(TransitionDemoPage, {\n    \"transition_name\": \"Fade\",\n    \"enter_preset\": UIFlowTransitionType.Type.FADE,\n    \"enter_duration\": 0.3,\n})"},
		{"title": "exit_transition — Exit animation", "code": "# Configure in .tscn:\nexit_transition = UIFlowTransitionRef\n    .get_exit_effect()"},
	],
	"UIFlowDemoComponents": [
		{"title": "UIFlowUI.Toast — Notification", "code": "UIFlowUI.Toast.show_toast(\n    \"Hello!\", \"info\", 3.0)"},
		{"title": "UIFlowUI.Confirm — Confirm dialog", "code": "UIFlowUI.Confirm.show_confirm(\n    \"Confirm\", \"Are you sure?\",\n    func(): print(\"OK\"),\n    func(): print(\"Cancel\"))"},
		{"title": "UIFlowUI.Alert — Alert dialog", "code": "UIFlowUI.Alert.show_alert(\n    \"Alert\", \"Something happened.\")"},
	],
	"UIFlowDemoTheme": [
		{"title": "apply_builtin_theme — Switch theme", "code": "UIFlow.apply_builtin_theme(\"dark\")\nUIFlow.apply_builtin_theme(\"light\")"},
	],
	"TransitionDemoPage": [
		{"title": "enter_transition — Entry animation", "code": "var effect := UIFlowFadeEffect.new()\neffect.duration = 0.3\nvar ref := UIFlowTransitionRef.new()\nref.enter_effect = effect\nenter_transition = ref"},
	],
}


func _ready() -> void:
	_setup_code_panel()
	await get_tree().process_frame
	UIFlow.push(DemoHub)


func _setup_code_panel() -> void:
	_code_panel = UIFlowCodePanel.new()
	_code_panel.name = "CodePanel"
	add_child(_code_panel)

	UIFlow.page_opened.connect(_on_page_opened)


func _on_page_opened(page_class: GDScript) -> void:
	var class_name_str: String = page_class.get_global_name()
	var snippets: Array = _PAGE_SNIPPETS.get(class_name_str, [])
	if not snippets.is_empty():
		_code_panel.show_snippets(class_name_str, snippets)
