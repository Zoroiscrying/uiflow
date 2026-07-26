## Workflow glue components demo — with per-section explanations.
##
## Highlights [UIFlowChildrenSwitcher] driving **multiple** child nodes in one
## [method UIFlowChildrenSwitcher.set_state] call (icon + title + detail + action).
class_name UIFlowDemoWorkflow extends UIFlowPage

var _pool: UIFlowChildPool
var _pool_box: HBoxContainer
var _switcher: UIFlowChildrenSwitcher
var _sw_action: Button
var _sw_state_hint: Label
var _vis_group: UIFlowVisibilityGroup
var _hold_label: Label
var _hold_count: int = 0
var _cooldown_label: Label
var _focus_edit: LineEdit
var _open_btn: Button
var _axis_slider: HSlider
var _axis_value_label: Label
var _action_bar: UIFlowActionBar


func _on_created(_data: Variant = null) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.1, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 56)
	add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)

	var title := Label.new()
	title.text = "Workflow Glue Components"
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	vbox.add_child(_blurb(
		"Free-tier scene glue: drop these on buttons/panels to avoid boilerplate for push, visibility, cooldowns, and similar."
		+ " Pro stays focused on recipes, cross-component drag-and-drop, Focus Studio, and other multipliers."
		+ "\nEach section below has a short description. For ChildrenSwitcher, watch one set_state update a whole group of children."
	))

	_add_nav_section(vbox)
	_add_switcher_section(vbox)
	_add_visibility_section(vbox)
	_add_pool_section(vbox)
	_add_axis_section(vbox)
	_add_input_section(vbox)
	_add_cooldown_section(vbox)
	_add_focus_section(vbox)

	_setup_action_bar()


func _add_nav_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "PageOpener / PageCloser",
		"Declare open/close on a Button instead of writing pressed → UIFlow.push/pop in script."
		+ " Opener supports push / replace / push_async / push_instance; Closer supports pop / pop_to_root / close_by_script.")

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)

	_open_btn = Button.new()
	_open_btn.text = "Open DialogPage"
	row.add_child(_open_btn)
	var opener := UIFlowPageOpener.new()
	opener.page_script = load("res://addons/ui_flow/examples/dialog_page.gd") as Script
	opener.mode = UIFlowPageOpener.Mode.PUSH
	_open_btn.add_child(opener)

	var back_btn := Button.new()
	back_btn.text = "Back (pop)"
	row.add_child(back_btn)
	var closer := UIFlowPageCloser.new()
	closer.mode = UIFlowPageCloser.Mode.POP
	back_btn.add_child(closer)


func _add_switcher_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "ChildrenSwitcher (multi-target)",
		"Core value: one state drives common properties on many children at once (visible / modulate / disabled / font_size …)."
		+ " Use it for card selected/disabled, slot empty/filled, wizard steps — one set_state aligns the whole group."
		+ "\nThis item card: Idle / Selected / Disabled update icon, title, detail, and action button together.")

	_switcher = UIFlowChildrenSwitcher.new()
	_switcher.custom_minimum_size = Vector2(0, 96)
	vbox.add_child(_switcher)

	var card := PanelContainer.new()
	card.name = "Card"
	_switcher.add_child(card)

	var row := HBoxContainer.new()
	row.name = "Row"
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var icon := Label.new()
	icon.name = "Icon"
	icon.text = "◆"
	icon.add_theme_font_size_override("font_size", 28)
	icon.custom_minimum_size = Vector2(40, 0)
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(icon)

	var text_col := VBoxContainer.new()
	text_col.name = "Text"
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_col)

	var title_lbl := Label.new()
	title_lbl.name = "Title"
	title_lbl.text = "Iron Sword"
	title_lbl.add_theme_font_size_override("font_size", 18)
	text_col.add_child(title_lbl)

	var detail := Label.new()
	detail.name = "Detail"
	detail.text = "ATK +12  ·  Common"
	detail.modulate = Color(1, 1, 1, 0.65)
	text_col.add_child(detail)

	_sw_action = Button.new()
	_sw_action.name = "Action"
	_sw_action.text = "Equip"
	_sw_action.custom_minimum_size = Vector2(88, 36)
	row.add_child(_sw_action)

	_switcher.states = [
		_card_state("idle",
			Color(0.75, 0.75, 0.8), Color.WHITE, Color(1, 1, 1, 0.65), 18, false),
		_card_state("selected",
			Color(0.35, 0.85, 1.0), Color(0.75, 0.95, 1.0), Color(0.55, 0.9, 1.0, 0.95), 20, false),
		_card_state("disabled",
			Color(0.35, 0.35, 0.38), Color(0.5, 0.5, 0.52), Color(1, 1, 1, 0.35), 18, true),
	]
	_switcher.initial_state = 0
	_switcher.state_changed.connect(_on_switcher_state_changed)

	_sw_state_hint = Label.new()
	_sw_state_hint.text = "Current state: idle — icon / title / detail / button updated together"
	_sw_state_hint.modulate = Color(1, 1, 1, 0.55)
	_sw_state_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_sw_state_hint)

	var btns := HBoxContainer.new()
	btns.add_theme_constant_override("separation", 8)
	vbox.add_child(btns)
	var names: PackedStringArray = ["Idle", "Selected", "Disabled"]
	for i in 3:
		var btn := Button.new()
		btn.text = names[i]
		var idx: int = i
		btn.pressed.connect(func(): _switcher.set_state(idx, false))
		btns.add_child(btn)


func _card_state(
	state_name: String,
	icon_color: Color,
	title_color: Color,
	detail_color: Color,
	title_size: int,
	action_disabled: bool,
) -> UIFlowVisualState:
	var icon_p := UIFlowVisualPatch.new()
	icon_p.set_modulate = true
	icon_p.modulate = icon_color

	var title_p := UIFlowVisualPatch.new()
	title_p.set_modulate = true
	title_p.modulate = title_color
	title_p.set_font_size = true
	title_p.font_size = title_size

	var detail_p := UIFlowVisualPatch.new()
	detail_p.set_visible = true
	detail_p.visible = true
	detail_p.set_modulate = true
	detail_p.modulate = detail_color

	var action_p := UIFlowVisualPatch.new()
	action_p.set_disabled = true
	action_p.disabled = action_disabled
	action_p.set_modulate = true
	action_p.modulate = Color(0.55, 0.55, 0.55) if action_disabled else Color.WHITE

	return UIFlowVisualState.new(state_name, [
		UIFlowVisualTarget.new(NodePath("Card/Row/Icon"), icon_p),
		UIFlowVisualTarget.new(NodePath("Card/Row/Text/Title"), title_p),
		UIFlowVisualTarget.new(NodePath("Card/Row/Text/Detail"), detail_p),
		UIFlowVisualTarget.new(NodePath("Card/Row/Action"), action_p),
	])


func _on_switcher_state_changed(_index: int, state_name: String) -> void:
	_sw_state_hint.text = "Current state: %s — icon / title / detail / button updated together" % state_name
	match state_name:
		"idle":
			_sw_action.text = "Equip"
		"selected":
			_sw_action.text = "Equip ★"
		"disabled":
			_sw_action.text = "Locked"


func _add_visibility_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "VisibilityGroup",
		"Mutually exclusive visibility: only one target is shown (tab bodies, mode panels)."
		+ " Complements ChildrenSwitcher — Group picks which block is shown; Switcher styles children inside a block.")

	var panel := VBoxContainer.new()
	vbox.add_child(panel)

	var a := Label.new()
	a.name = "PanelA"
	a.text = "Panel A — inventory filters"
	panel.add_child(a)
	var b := Label.new()
	b.name = "PanelB"
	b.text = "Panel B — craft recipes"
	b.visible = false
	panel.add_child(b)
	var c := Label.new()
	c.name = "PanelC"
	c.text = "Panel C — stats summary"
	c.visible = false
	panel.add_child(c)

	_vis_group = UIFlowVisibilityGroup.new()
	_vis_group.targets = [NodePath("../PanelA"), NodePath("../PanelB"), NodePath("../PanelC")]
	panel.add_child(_vis_group)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)
	for i in 3:
		var btn := Button.new()
		btn.text = "Show %s" % char(65 + i)
		var idx: int = i
		btn.pressed.connect(func(): _vis_group.set_active(idx))
		row.add_child(btn)


func _add_pool_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "ChildPool",
		"Count-driven children (ReserveChildren): ensure_count(n, init_fn)."
		+ " Good for fixed slots (6 skill slots, hotbar) when you do not need ListBinder’s data-array binding.")

	_pool_box = HBoxContainer.new()
	_pool_box.add_theme_constant_override("separation", 6)
	vbox.add_child(_pool_box)

	_pool = UIFlowChildPool.new()
	_pool.container_path = NodePath("..")
	var slot := Button.new()
	slot.custom_minimum_size = Vector2(72, 36)
	slot.text = "#"
	var packed := PackedScene.new()
	packed.pack(slot)
	slot.queue_free()
	_pool.template = packed
	_pool_box.add_child(_pool)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)
	for n in [0, 3, 6]:
		var btn := Button.new()
		btn.text = "Ensure %d" % n
		var count: int = n
		btn.pressed.connect(func():
			_pool.ensure_count(count, func(child: Node, index: int) -> void:
				if child is Button:
					(child as Button).text = str(index + 1)
			)
		)
		row.add_child(btn)


func _add_axis_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "AxisBinder (right stick → Slider)",
		"UIFlowAxisBinder: focus a Range, then tilt the right stick to adjust."
		+ " Declares UIInputActionNode (AXIS_1D) so ActionBar shows RS · Adjust."
		+ " Left stick stays with focus navigation; keyboard ←→ still works on a focused HSlider.")

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	vbox.add_child(row)

	_axis_slider = HSlider.new()
	_axis_slider.min_value = 0.0
	_axis_slider.max_value = 100.0
	_axis_slider.step = 1.0
	_axis_slider.value = 40.0
	_axis_slider.custom_minimum_size = Vector2(280, 28)
	_axis_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_axis_slider.focus_mode = Control.FOCUS_ALL
	row.add_child(_axis_slider)

	_axis_value_label = Label.new()
	_axis_value_label.custom_minimum_size = Vector2(72, 0)
	_axis_value_label.text = "40"
	row.add_child(_axis_value_label)

	_axis_slider.value_changed.connect(func(v: float):
		_axis_value_label.text = str(int(round(v)))
	)

	var binder := UIFlowAxisBinder.new()
	binder.target_path = NodePath("..")
	binder.axis_source = UIFlowAxisBinder.AxisSource.RIGHT_STICK_X
	binder.require_focus = true
	binder.declare_action = true
	binder.action_label = "Adjust"
	# Always list in ActionBar so players see RS · Adjust before focusing the slider.
	binder.action_enabled_when_active = false
	_axis_slider.add_child(binder)


func _setup_action_bar() -> void:
	var close_act := UIInputActionNode.new()
	close_act.action_name = &"close"
	close_act.godot_action = &"ui_cancel"
	close_act.label = "Back"
	add_child(close_act)

	_action_bar = UIFlowActionBar.new()
	_action_bar.auto_bind = false
	_action_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_action_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_action_bar.offset_top = -48
	_action_bar.offset_bottom = -8
	_action_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_action_bar)


func _add_input_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "InputRelay + HoldRepeater",
		"InputRelay: local InputMap → signal (optional focus/visibility gates). Keep UIInputActionNode for page-level actions."
		+ "\nHoldRepeater: keep firing ticks while held — quantity steppers, fast list scroll.")

	_hold_label = Label.new()
	_hold_label.text = "Hold ticks: 0  (hold ui_right)"
	vbox.add_child(_hold_label)

	var field := LineEdit.new()
	field.placeholder_text = "Focus me, then press ui_accept (InputRelay)"
	field.custom_minimum_size = Vector2(320, 36)
	vbox.add_child(field)

	var relay := UIFlowInputRelay.new()
	relay.godot_action = &"ui_accept"
	relay.require_focus = true
	relay.require_visible = true
	relay.unhandled_only = false
	relay.triggered.connect(func(_e):
		UIFlowUI.Toast.show_toast("InputRelay: ui_accept", "info")
	)
	field.add_child(relay)

	var repeater := UIFlowHoldRepeater.new()
	repeater.godot_action = &"ui_right"
	repeater.fire_on_press = true
	repeater.tick.connect(func():
		_hold_count += 1
		_hold_label.text = "Hold ticks: %d  (hold ui_right)" % _hold_count
	)
	add_child(repeater)


func _add_cooldown_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "CooldownGate",
		"Rate-limit a button to stop double-opens. Listen to accepted / rejected, or call try_pass() from your own logic.")

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)

	var btn := Button.new()
	btn.text = "Spam me (0.8s cooldown)"
	row.add_child(btn)

	_cooldown_label = Label.new()
	_cooldown_label.text = "Ready"
	row.add_child(_cooldown_label)

	var gate := UIFlowCooldownGate.new()
	gate.cooldown_seconds = 0.8
	gate.auto_bind_parent = true
	gate.accepted.connect(func():
		_cooldown_label.text = "Accepted"
		UIFlowUI.Toast.show_toast("Cooldown passed", "success")
	)
	gate.rejected.connect(func():
		_cooldown_label.text = "Rejected (cooling)"
	)
	btn.add_child(gate)


func _add_focus_section(vbox: VBoxContainer) -> void:
	_add_section_header(vbox, "AutoFocus",
		"Grab focus on a nested Control via apply_focus(). Page-level default here uses UIFlow.set_default_focus(Open DialogPage);"
		+ " press Apply AutoFocus below to demo focusing this LineEdit without stealing the page default.")

	_focus_edit = LineEdit.new()
	_focus_edit.placeholder_text = "Target for AutoFocus (use button below)"
	_focus_edit.custom_minimum_size = Vector2(320, 36)
	vbox.add_child(_focus_edit)
	var auto := UIFlowAutoFocus.new()
	auto.focus_path = NodePath("..")
	# Page default focus is Open DialogPage; demo AutoFocus on demand so it does not steal.
	auto.focus_on_ready = false
	auto.focus_on_page_shown = false
	_focus_edit.add_child(auto)

	var focus_demo_btn := Button.new()
	focus_demo_btn.text = "Apply AutoFocus"
	focus_demo_btn.pressed.connect(auto.apply_focus)
	vbox.add_child(focus_demo_btn)


func _add_section_header(vbox: VBoxContainer, title: String, description: String) -> void:
	vbox.add_child(HSeparator.new())
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(label)
	vbox.add_child(_blurb(description))


func _blurb(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.modulate = Color(1, 1, 1, 0.62)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _on_opened(_data: Variant = null) -> void:
	if _switcher:
		_switcher.set_state(0, false)
	if _open_btn:
		UIFlow.set_default_focus(_open_btn)
	if _action_bar:
		_action_bar.bind_page(self)


func _on_back() -> void:
	UIFlow.pop()
