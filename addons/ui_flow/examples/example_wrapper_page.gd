## Example Wrapper Page — embeds an example scene inside a UIFlow page.
##
## This wrapper provides a back button and title bar,
## then instantiates the example's main scene as content.
extends UIFlowPage

var _example_scene: Control


func _on_opened(data: Dictionary = {}) -> void:
	var scene_name: String = data.get("scene_name", "")
	var title: String = data.get("title", "Example")

	$VBox/Header/Title.text = title

	# Load and instantiate the example scene
	var scene_path: String = "res://addons/ui_flow/examples/%s/main.tscn" % scene_name.to_lower()
	# Try the examples directory first
	var alt_path: String = "res://addons/ui_flow/examples/%s/main.tscn" % _snake_case(scene_name)

	var path: String = ""
	if ResourceLoader.exists(scene_path):
		path = scene_path
	elif ResourceLoader.exists(alt_path):
		path = alt_path
	else:
		# Try UIScene directory
		var uiscene_path: String = "res://UIScene/%s.tscn" % scene_name
		if ResourceLoader.exists(uiscene_path):
			path = uiscene_path

	if path.is_empty():
		$VBox/Content/ErrorLabel.text = "Scene not found: %s" % scene_name
		$VBox/Content/ErrorLabel.visible = true
		return

	var scene: PackedScene = load(path)
	if scene:
		_example_scene = scene.instantiate()
		_example_scene.set_anchors_preset(Control.PRESET_FULL_RECT)
		$VBox/Content.add_child(_example_scene)

	$VBox/Header/BackButton.pressed.connect(_on_back)


func _on_closed() -> void:
	if _example_scene and is_instance_valid(_example_scene):
		$VBox/Content.remove_child(_example_scene)
		_example_scene.queue_free()
		_example_scene = null


func _on_back() -> void:
	UIFlow.pop()


func _snake_case(input: String) -> String:
	var result: String = ""
	for i in range(input.length()):
		var c: String = input[i]
		if c.to_upper() == c and c.to_lower() != c and i > 0:
			result += "_"
		result += c.to_lower()
	return result
