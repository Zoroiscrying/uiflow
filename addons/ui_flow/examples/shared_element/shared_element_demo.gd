extends Control

const SharedElementHubPage := preload("res://addons/ui_flow/examples/shared_element/shared_element_hub_page.gd")


func _ready() -> void:
	UIFlow.push(SharedElementHubPage)
