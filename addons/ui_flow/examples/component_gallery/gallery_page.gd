## Gallery page - showcases all UIFlow components and transitions.
class_name GalleryPage extends UIFlowPage


func _ready() -> void:
	# Toast
	$Margin/Scroll/VBox/ToastSection/Buttons/InfoBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("This is an info message.", UIFlowToast.Type.INFO)
	)
	$Margin/Scroll/VBox/ToastSection/Buttons/SuccessBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("Operation succeeded!", UIFlowToast.Type.SUCCESS)
	)
	$Margin/Scroll/VBox/ToastSection/Buttons/WarningBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("Warning: low memory.", UIFlowToast.Type.WARNING)
	)
	$Margin/Scroll/VBox/ToastSection/Buttons/ErrorBtn.pressed.connect(func():
		UIFlowUI.Toast.show_toast("Connection failed!", UIFlowToast.Type.ERROR)
	)

	# Dialogs
	$Margin/Scroll/VBox/DialogSection/Buttons/ConfirmBtn.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Confirm Action", "Do you want to proceed?",
			func(): UIFlowUI.Toast.show_toast("Confirmed!", UIFlowToast.Type.SUCCESS),
			func(): UIFlowUI.Toast.show_toast("Canceled.", UIFlowToast.Type.INFO)
		)
	)
	$Margin/Scroll/VBox/DialogSection/Buttons/AlertBtn.pressed.connect(func():
		UIFlowUI.Alert.show_alert("Information", "This is an alert dialog. Click OK to dismiss.")
	)

	# Transitions
	$Margin/Scroll/VBox/TransSection/Buttons/FadeBtn.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.FADE, "Fade")
	)
	$Margin/Scroll/VBox/TransSection/Buttons/SlideLBtn.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.SLIDE_LEFT, "Slide Left")
	)
	$Margin/Scroll/VBox/TransSection/Buttons/SlideRBtn.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.SLIDE_RIGHT, "Slide Right")
	)
	$Margin/Scroll/VBox/TransSection/Buttons/ScaleBtn.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.SCALE, "Scale")
	)

	# Animations
	$Margin/Scroll/VBox/AnimSection/Buttons/BounceBtn.pressed.connect(func():
		_demo_bounce()
	)
	$Margin/Scroll/VBox/AnimSection/Buttons/StaggerBtn.pressed.connect(func():
		_demo_stagger()
	)


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus($Margin/Scroll/VBox/ToastSection/Buttons/InfoBtn)


func _on_resume() -> void:
	UIFlow.set_default_focus($Margin/Scroll/VBox/ToastSection/Buttons/InfoBtn)


func _demo_transition(type: UIFlowTransitionType.Type, label: String) -> void:
	var page: TransitionDemoPage = UIFlow.push(TransitionDemoPage, {}, type) as TransitionDemoPage
	page.set_transition_name(label)


func _demo_bounce() -> void:
	var title: Control = $Margin/Scroll/VBox/Title
	var original: float = title.offset_top
	title.offset_top = original - 20
	var tween: Tween = title.create_tween()
	tween.tween_property(title, "offset_top", original, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _demo_stagger() -> void:
	var buttons := [
		$Margin/Scroll/VBox/ToastSection/Buttons/InfoBtn,
		$Margin/Scroll/VBox/ToastSection/Buttons/SuccessBtn,
		$Margin/Scroll/VBox/ToastSection/Buttons/WarningBtn,
		$Margin/Scroll/VBox/ToastSection/Buttons/ErrorBtn,
	]
	var seq = UIFlow.sequencer()
	for btn in buttons:
		btn.modulate.a = 0.0
		seq.add(btn, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.15).delay(0.08)
	seq.play()
