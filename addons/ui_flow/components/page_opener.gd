## Declares how to open a UIFlow page — drop on a Button (or call [method open]).
##
## Prefer [member page_script] for [code]push[/code] / [code]replace[/code] / [code]push_async[/code]
## (must be a [GDScript] with [code]class_name[/code]). Use [member page_scene] for
## [enum Mode.PUSH_INSTANCE] when you need a concrete PackedScene.
class_name UIFlowPageOpener extends Node

enum Mode {
	PUSH,
	REPLACE,
	PUSH_ASYNC,
	PUSH_INSTANCE,
}

signal opened(page: Control)
signal failed(reason: String)

@export var mode: Mode = Mode.PUSH
## GDScript page class (with class_name). Used by PUSH / REPLACE / PUSH_ASYNC.
@export var page_script: Script
## PackedScene used by PUSH_INSTANCE (and as fallback when script is empty).
@export var page_scene: PackedScene
@export var data: Dictionary = {}
## When true, connects to the parent Control's [member bind_signal] (default: Button.pressed).
@export var auto_bind_parent: bool = true
@export var bind_signal: StringName = &"pressed"


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if auto_bind_parent:
		_try_bind_parent()


func _try_bind_parent() -> void:
	var parent := get_parent()
	if parent == null or bind_signal.is_empty():
		return
	if parent.has_signal(bind_signal) and not parent.is_connected(bind_signal, open):
		parent.connect(bind_signal, open)


## Opens the configured page. Safe to call from code.
func open() -> void:
	if Engine.is_editor_hint():
		return
	if UIFlow == null:
		failed.emit("UIFlow autoload missing")
		return

	match mode:
		Mode.PUSH:
			var page_class := _resolve_page_class()
			if page_class == null:
				failed.emit("page_script / page_scene unresolved")
				return
			var page: Control = UIFlow.push(page_class, data)
			opened.emit(page)
		Mode.REPLACE:
			var page_class := _resolve_page_class()
			if page_class == null:
				failed.emit("page_script / page_scene unresolved")
				return
			var page: Control = UIFlow.replace(page_class, data)
			opened.emit(page)
		Mode.PUSH_ASYNC:
			var page_class := _resolve_page_class()
			if page_class == null:
				failed.emit("page_script / page_scene unresolved")
				return
			_open_async(page_class)
		Mode.PUSH_INSTANCE:
			if page_scene == null:
				failed.emit("page_scene required for PUSH_INSTANCE")
				return
			var instance: Control = page_scene.instantiate() as Control
			if instance == null:
				failed.emit("page_scene root is not a Control")
				return
			var page: Control = UIFlow.push_instance(instance, data)
			opened.emit(page)


func _open_async(page_class: GDScript) -> void:
	var page: Control = await UIFlow.push_async(page_class, data)
	opened.emit(page)


func _resolve_page_class() -> GDScript:
	if page_script is GDScript:
		return page_script as GDScript
	if page_scene != null:
		var temp: Node = page_scene.instantiate()
		var script: Script = temp.get_script()
		temp.free()
		if script is GDScript:
			return script as GDScript
	return null
