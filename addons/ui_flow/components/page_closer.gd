## Closes / pops the current UIFlow page — drop on a Back/Cancel Button.
class_name UIFlowPageCloser extends Node

enum Mode {
	POP,
	POP_TO_ROOT,
	CLOSE_BY_SCRIPT,
}

@export var mode: Mode = Mode.POP
## Used when [member mode] is CLOSE_BY_SCRIPT.
@export var page_script: Script
@export var auto_bind_parent: bool = true
@export var bind_signal: StringName = &"pressed"

signal closed


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if auto_bind_parent:
		_try_bind_parent()


func _try_bind_parent() -> void:
	var parent := get_parent()
	if parent == null or bind_signal.is_empty():
		return
	if parent.has_signal(bind_signal) and not parent.is_connected(bind_signal, close_page):
		parent.connect(bind_signal, close_page)


func close_page() -> void:
	if Engine.is_editor_hint():
		return
	if UIFlow == null:
		return
	match mode:
		Mode.POP:
			UIFlow.pop()
		Mode.POP_TO_ROOT:
			UIFlow.pop_to_root()
		Mode.CLOSE_BY_SCRIPT:
			if page_script is GDScript:
				UIFlow.close(page_script as GDScript)
	closed.emit()
