@tool
## Elastic scale effect — scale animation with bounce, elastic, or back transition curves.
class_name UIFlowElasticScaleEffect extends UIFlowScaleEffect

enum Preset { BOUNCE, ELASTIC, BACK }

## Preset transition curve. Updating this sets the inherited trans_type.
@export var preset: Preset = Preset.BOUNCE:
	set(value):
		preset = value
		_apply_preset()


func _init() -> void:
	super._init()
	_apply_preset()


func _apply_preset() -> void:
	match preset:
		Preset.BOUNCE:
			trans_type = Tween.TRANS_BOUNCE
		Preset.ELASTIC:
			trans_type = Tween.TRANS_ELASTIC
		Preset.BACK:
			trans_type = Tween.TRANS_BACK
