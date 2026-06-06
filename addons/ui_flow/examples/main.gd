## Main entry point — 3D game world with UIFlow UI overlay.
extends Node3D

func _ready() -> void:
	await get_tree().process_frame
	var page = UIFlow.push(ExampleHub, {}, UIFlowTransitionType.Type.NONE)
	print("UIFlow: Pushed ExampleHub, instance = ", page)
	if page:
		print("UIFlow: Page size = ", page.size, " visible = ", page.visible)
		print("UIFlow: Container size = ", UIFlow._page_container.size)
		print("UIFlow: Container children = ", UIFlow._page_container.get_child_count())
