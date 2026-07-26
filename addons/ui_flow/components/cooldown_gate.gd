## Rate-limits an action (e.g. Button.pressed) to prevent double-opens.
class_name UIFlowCooldownGate extends Node

signal accepted
signal rejected

@export var cooldown_seconds: float = 0.5
@export var auto_bind_parent: bool = true
@export var bind_signal: StringName = &"pressed"
@export var enabled: bool = true

var _remaining: float = 0.0


func _ready() -> void:
	set_process(false)
	if Engine.is_editor_hint():
		return
	if auto_bind_parent:
		_try_bind_parent()


func _try_bind_parent() -> void:
	var parent := get_parent()
	if parent == null or bind_signal.is_empty():
		return
	if not parent.has_signal(bind_signal):
		return
	# Insert gate: disconnect is not needed; we listen and parent may also listen.
	# Prefer wrapping: connect our handler; callers should use [signal accepted]
	# OR call [method try_pass] from their own handler.
	if not parent.is_connected(bind_signal, _on_parent_signal):
		parent.connect(bind_signal, _on_parent_signal)


func _process(delta: float) -> void:
	if _remaining <= 0.0:
		set_process(false)
		return
	_remaining = maxf(_remaining - delta, 0.0)
	if _remaining <= 0.0:
		set_process(false)


func _on_parent_signal(_a: Variant = null, _b: Variant = null, _c: Variant = null, _d: Variant = null) -> void:
	try_pass()


## Returns true and starts cooldown when allowed; otherwise emits [signal rejected].
func try_pass() -> bool:
	if not enabled:
		accepted.emit()
		return true
	if _remaining > 0.0:
		rejected.emit()
		return false
	_remaining = cooldown_seconds
	set_process(true)
	accepted.emit()
	return true


func is_cooling_down() -> bool:
	return _remaining > 0.0


func remaining() -> float:
	return _remaining


func reset() -> void:
	_remaining = 0.0
	set_process(false)
