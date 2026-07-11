class_name AsyncTestPage extends UIFlowPage


func _init() -> void:
	var effect := UIFlowFadeEffect.new()
	effect.duration = 0.05
	exit_effect = effect
