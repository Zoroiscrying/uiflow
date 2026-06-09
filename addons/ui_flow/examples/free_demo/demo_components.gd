## Components Demo — Toast, Confirm, Alert, Tooltip.
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


func _on_opened(_data: Variant = null) -> void:
	UIFlow.set_default_focus($Panel/VBox/ToastSection/Buttons/InfoBtn)


func _on_back() -> void:
	UIFlow.pop()
