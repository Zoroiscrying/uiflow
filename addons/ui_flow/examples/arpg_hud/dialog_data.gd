## DialogData — defines a dialog sequence with NPC name and lines.
class_name DialogData extends Resource

## NPC display name.
@export var npc_name: String = "NPC"

## NPC portrait texture.
@export var portrait: Texture2D = null

## Dialog lines (each line is a Dictionary with "text" and optional "options").
@export var lines: Array[Dictionary] = []

## Add a simple text line.
func add_line(text: String) -> DialogData:
	lines.append({"text": text})
	return self

## Add a line with choices.
func add_choice(text: String, options: Array[Dictionary]) -> DialogData:
	lines.append({"text": text, "options": options})
	return self

## Quick builder: create a simple dialog with text lines.
static func create(npc: String, dialog_lines: Array[String]) -> DialogData:
	var data := DialogData.new()
	data.npc_name = npc
	for line in dialog_lines:
		data.add_line(line)
	return data
