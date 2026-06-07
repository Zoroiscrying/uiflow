## Transition demo page — configured via push data.
##
## Usage:
##   UIFlow.push(TransitionDemoPage, {
##       "transition_name": "Fade",
##       "enter_preset": UIFlowTransitionType.Type.FADE,
##       "enter_duration": 0.3,
##   })
class_name TransitionDemoPage extends UIFlowPage

@onready var _back_button: Button = $Center/BackButton


func _ready() -> void:
	_back_button.pressed.connect(func(): UIFlow.pop())
	# Default exit animation
	var fade := UIFlowTransitionRef.new()
	fade.source = UIFlowTransitionRef.Source.PRESET
	fade.preset = UIFlowTransitionType.Type.FADE
	fade.duration = 0.2
	exit_transition = fade


func _on_created(data: Dictionary = {}) -> void:
	# Configure enter transition from data
	var preset = data.get("enter_preset", UIFlowTransitionType.Type.NONE)
	var duration: float = data.get("enter_duration", 0.3)
	var ease = data.get("enter_ease", Tween.EASE_IN_OUT)
	var trans = data.get("enter_trans", Tween.TRANS_LINEAR)

	if preset != UIFlowTransitionType.Type.NONE:
		var ref := UIFlowTransitionRef.new()
		ref.source = UIFlowTransitionRef.Source.PRESET
		ref.preset = preset
		ref.duration = duration
		ref.ease_type = ease
		ref.trans_type = trans
		enter_transition = ref

	var trans_name: String = data.get("transition_name", "Unknown")
	$Center/NameLabel.text = "Transition: %s" % trans_name


func _on_opened(_data: Dictionary = {}) -> void:
	UIFlow.set_default_focus(_back_button)
