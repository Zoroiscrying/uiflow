## Resolves Kenney (CC0) input-prompt textures for the active device family.
##
## Semantic keys: [code]accept[/code], [code]cancel[/code], [code]interact[/code],
## [code]pause[/code], [code]backpack[/code], [code]equipment[/code], [code]f1[/code],
## [code]tab_prev[/code] / [code]tab_next[/code] (shoulder / brackets),
## [code]dpad[/code], [code]stick[/code] / [code]stick_r[/code], and arrows.
class_name UIFlowInputPromptIcons extends RefCounted

const DIR := "res://addons/ui_flow/assets/input_prompts/"

const _KB: Dictionary = {
	&"accept": "kb_enter.png",
	&"cancel": "kb_esc.png",
	&"pause": "kb_esc.png",
	&"interact": "kb_e.png",
	&"backpack": "",  # badge "I"
	&"equipment": "",  # badge "P"
	&"f1": "kb_f1.png",
	&"tab_prev": "",  # badge "["
	&"tab_next": "",  # badge "]"
	&"up": "kb_up.png",
	&"down": "kb_down.png",
	&"left": "kb_left.png",
	&"right": "kb_right.png",
	&"dpad": "kb_up.png",
	&"stick": "kb_up.png",
	&"stick_r": "",  # badge "←→" (HSlider arrows); no dedicated R-stick KB glyph
}

const _PAD: Dictionary = {
	&"accept": "xbox_a.png",
	&"cancel": "xbox_b.png",
	&"pause": "xbox_b.png",
	&"interact": "xbox_a.png",
	&"backpack": "xbox_y.png",
	&"equipment": "xbox_x.png",
	&"f1": "kb_f1.png",
	&"tab_prev": "",  # badge "LB" (no Kenney LB asset vendored yet)
	&"tab_next": "",  # badge "RB"
	&"up": "xbox_dpad.png",
	&"down": "xbox_dpad.png",
	&"left": "xbox_dpad.png",
	&"right": "xbox_dpad.png",
	&"dpad": "xbox_dpad.png",
	&"stick": "xbox_stick_l.png",
	&"stick_r": "",  # badge "RS" until a right-stick Kenney asset is vendored
}

## Maps Godot InputMap action names → semantic glyph keys.
const ACTION_SEMANTICS: Dictionary = {
	&"ui_accept": &"accept",
	&"ui_cancel": &"cancel",
	&"interact": &"interact",
	&"open_backpack": &"backpack",
	&"open_equipment": &"equipment",
	&"open_help": &"f1",
	&"pause": &"pause",
	&"ui_tab_prev": &"tab_prev",
	&"ui_tab_next": &"tab_next",
	## Prompt-only / AxisBinder default — need not exist in InputMap.
	&"ui_axis_adjust": &"stick_r",
}

static var _cache: Dictionary = {}


## Texture for [param semantic] on [param kind], or null if missing / badge-only.
static func texture_for(semantic: StringName, kind: UIFlowInputDevice.Kind = UIFlowInputDevice.Kind.KEYBOARD_MOUSE) -> Texture2D:
	var table: Dictionary = _PAD if kind == UIFlowInputDevice.Kind.GAMEPAD else _KB
	var file: String = String(table.get(semantic, ""))
	if file.is_empty():
		return null
	var path := DIR + file
	if _cache.has(path):
		return _cache[path] as Texture2D
	if not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path) as Texture2D
	_cache[path] = tex
	return tex


## Prefer [member UIFlow.InputDevice] when available.
static func texture_for_current(semantic: StringName) -> Texture2D:
	return texture_for(semantic, _current_kind())


## Semantic key for a Godot InputMap action, or empty if unknown.
static func semantic_for_action(godot_action: StringName) -> StringName:
	return ACTION_SEMANTICS.get(godot_action, &"") as StringName


## Texture for a Godot InputMap action on the current device.
static func texture_for_action(godot_action: StringName) -> Texture2D:
	var semantic: StringName = semantic_for_action(godot_action)
	if semantic.is_empty():
		return null
	return texture_for_current(semantic)


## Short fallback badge text when no texture is available.
static func badge_for(semantic: StringName, kind: UIFlowInputDevice.Kind = UIFlowInputDevice.Kind.KEYBOARD_MOUSE) -> String:
	if kind == UIFlowInputDevice.Kind.GAMEPAD:
		match semantic:
			&"accept", &"interact":
				return "A"
			&"cancel", &"pause":
				return "B"
			&"backpack":
				return "Y"
			&"equipment":
				return "X"
			&"tab_prev":
				return "LB"
			&"tab_next":
				return "RB"
			&"dpad":
				return "+"
			&"stick":
				return "L"
			&"stick_r":
				return "RS"
			_:
				return String(semantic).left(1).to_upper()
	match semantic:
		&"accept":
			return "Enter"
		&"cancel", &"pause":
			return "Esc"
		&"interact":
			return "E"
		&"backpack":
			return "I"
		&"equipment":
			return "P"
		&"f1":
			return "F1"
		&"tab_prev":
			return "["
		&"tab_next":
			return "]"
		&"stick_r":
			return "←→"
		_:
			return String(semantic).left(1).to_upper()


static func badge_for_action(godot_action: StringName) -> String:
	var semantic: StringName = semantic_for_action(godot_action)
	if semantic.is_empty():
		return String(godot_action)
	return badge_for(semantic, _current_kind())


static func _current_kind() -> UIFlowInputDevice.Kind:
	if UIFlow != null and UIFlow.InputDevice != null:
		return UIFlow.InputDevice.kind
	return UIFlowInputDevice.Kind.KEYBOARD_MOUSE
