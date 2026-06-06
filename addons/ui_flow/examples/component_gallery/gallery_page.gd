## Gallery page — showcases all UIFlow components and transitions.
extends UIFlowPage

func _ready() -> void:
	# Toast buttons
	$Scroll/VBox/ToastSection/InfoButton.pressed.connect(func():
		UIFlowUI.Toast.show("This is an info message.", UIFlowToast.Type.INFO)
	)
	$Scroll/VBox/ToastSection/SuccessButton.pressed.connect(func():
		UIFlowUI.Toast.show("Operation succeeded!", UIFlowToast.Type.SUCCESS)
	)
	$Scroll/VBox/ToastSection/WarningButton.pressed.connect(func():
		UIFlowUI.Toast.show("Warning: low memory.", UIFlowToast.Type.WARNING)
	)
	$Scroll/VBox/ToastSection/ErrorButton.pressed.connect(func():
		UIFlowUI.Toast.show("Connection failed!", UIFlowToast.Type.ERROR)
	)

	# Dialog buttons
	$Scroll/VBox/DialogSection/ConfirmButton.pressed.connect(func():
		UIFlowUI.Confirm.show("Confirm Action", "Do you want to proceed?",
			func(): UIFlowUI.Toast.show("Confirmed!", UIFlowToast.Type.SUCCESS),
			func(): UIFlowUI.Toast.show("Canceled.", UIFlowToast.Type.INFO)
		)
	)
	$Scroll/VBox/DialogSection/AlertButton.pressed.connect(func():
		UIFlowUI.Alert.show("Information", "This is an alert dialog. Click OK to dismiss.")
	)

	# Transition buttons
	$Scroll/VBox/TransitionSection/FadeButton.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.FADE)
	)
	$Scroll/VBox/TransitionSection/SlideLeftButton.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.SLIDE_LEFT)
	)
	$Scroll/VBox/TransitionSection/SlideRightButton.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.SLIDE_RIGHT)
	)
	$Scroll/VBox/TransitionSection/ScaleButton.pressed.connect(func():
		_demo_transition(UIFlowTransitionType.Type.SCALE)
	)

	# Animation demo
	$Scroll/VBox/AnimSection/BounceButton.pressed.connect(func():
		_demo_bounce()
	)
	$Scroll/VBox/AnimSection/StaggerButton.pressed.connect(func():
		_demo_stagger()
	)


func _on_enter(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus($Scroll/VBox/ToastSection/InfoButton)


func _demo_transition(type: UIFlowTransitionType.Type) -> void:
	var page: TransitionDemoPage = UIFlow.push(TransitionDemoPage, {}, type) as TransitionDemoPage
	page.set_transition_name(UIFlowTransitionType.get_name(type))


func _demo_bounce() -> void:
	# Bounce the title
	UIFlow.animate($Scroll/VBox/Title, UIFlowTweenProp.Prop.POSITION_Y,
		$Scroll/VBox/Title.position.y - 20, $Scroll/VBox/Title.position.y,
		0.4, Tween.EASE_OUT, Tween.TRANS_ELASTIC)


func _demo_stagger() -> void:
	# Stagger fade-in on toast section buttons
	var buttons := [
		$Scroll/VBox/ToastSection/InfoButton,
		$Scroll/VBox/ToastSection/SuccessButton,
		$Scroll/VBox/ToastSection/WarningButton,
		$Scroll/VBox/ToastSection/ErrorButton,
	]
	var seq = UIFlow.sequencer()
	for btn in buttons:
		btn.modulate.a = 0.0
		seq.add(btn, UIFlowTweenProp.Prop.MODULATE_A, 0.0, 1.0, 0.15).delay(0.08)
	seq.play()
