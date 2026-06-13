## Components Demo — Toast, Confirm, Alert, Tooltip, HoverHint, ContextMenu, DataGrid.
class_name UIFlowDemoComponents extends UIFlowPage

@onready var _back_button: Button = $Panel/VBox/BackButton


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())

	# Toast buttons
	$Panel/VBox/ToastSection/Buttons/InfoBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("This is an info message.", "info")
	)
	$Panel/VBox/ToastSection/Buttons/SuccessBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("Operation succeeded!", "success")
	)
	$Panel/VBox/ToastSection/Buttons/WarningBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("Warning: check your input.", "warning")
	)
	$Panel/VBox/ToastSection/Buttons/ErrorBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("Error occurred!", "error")
	)

	# Dialog buttons
	$Panel/VBox/DialogSection/Buttons/ConfirmBtn.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Confirm", "Are you sure?",
			func(): UIFlowUI.Toast.show_toast("Confirmed!", "success"),
			func(): UIFlowUI.Toast.show_toast("Canceled.", "info")
		)
	)
	$Panel/VBox/DialogSection/Buttons/AlertBtn.pressed.connect(func():
		UIFlowUI.Alert.show_alert("Alert", "This is an alert dialog.")
	)

	# Tooltip demo
	var tooltip_btn: Button = $Panel/VBox/TooltipSection/DemoBtn
	UIFlowTooltip.attach(tooltip_btn, "This is a tooltip! Hover to see it.")

	# HoverHint demo
	var hover_btn: Button = $Panel/VBox/HoverHintSection/DemoBtn
	UIFlowHoverHint.attach(hover_btn, "[b]Rich Text[/b]\nSupports BBCode\nHover hints follow the cursor.", true)

	# ContextMenu demo
	var menu_btn: Button = $Panel/VBox/ContextMenuSection/DemoBtn
	menu_btn.pressed.connect(_on_contextmenu_btn_pressed)

	# DataGrid demo
	_setup_datagrid()


func _on_contextmenu_btn_pressed() -> void:
	var menu := UIFlowContextMenu.new()
	menu.add_item("Option A", func():
		UIFlowUI.Toast.show_toast("Selected A", "info")
	)
	menu.add_item("Option B", func():
		UIFlowUI.Toast.show_toast("Selected B", "info")
	)
	menu.add_separator()
	menu.add_submenu("More Options")
	menu.show_at(get_global_mouse_position())


func _setup_datagrid() -> void:
	var grid = $Panel/VBox/DataGridSection/Grid
	grid.add_column("Name", 150, true)
	grid.add_column("Level", 80, true)
	grid.add_column("HP", 100, true)
	grid.set_data([
		["Warrior", "5", "150"],
		["Mage", "3", "80"],
		["Rogue", "7", "100"],
		["Paladin", "4", "200"],
	])
	grid.row_selected.connect(func(idx, data):
		UIFlowUI.Toast.show_toast("Selected: %s" % data[0], "info")
	)


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus($Panel/VBox/ToastSection/Buttons/InfoBtn)


func _on_back() -> void:
	UIFlow.pop()
