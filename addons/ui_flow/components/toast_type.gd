## UIFlowToastType — defines the visual style and behavior of a toast type.
##
## Create custom types in Inspector or code:
## [codeblock]
## var my_type = UIFlowToastType.new()
## my_type.bg_color = Color(0.2, 0.5, 0.8, 0.95)
## my_type.text_color = Color.WHITE
## my_type.label = "Achievement"
## my_type.icon = preload("res://icon_achievement.png")
## UIFlowUI.Toast.register_type("achievement", my_type)
## UIFlowUI.Toast.show("Boss Defeated!", "achievement")
## [/codeblock]
@tool
class_name UIFlowToastType extends Resource

## Background color.
@export var bg_color: Color = Color(0.2, 0.3, 0.5, 0.95)

## Text color.
@export var text_color: Color = Color.WHITE

## Font size.
@export var font_size: int = 16

## Optional icon displayed before text.
@export var icon: Texture2D = null

## Border color (transparent = no border).
@export var border_color: Color = Color.TRANSPARENT

## Border width.
@export var border_width: int = 0

## Corner radius.
@export var corner_radius: int = 8

## Content padding.
@export var padding: int = 12

## Default display duration in seconds.
@export var default_duration: float = 3.0

## Custom toast scene (optional, replaces default appearance).
## Must have a root Control with a "setup(message, type)" method.
@export var custom_scene: PackedScene = null

## Label text shown before the message (e.g., "Achievement Unlocked!").
@export var label: String = ""

## Sound to play when toast appears (optional).
@export var sound: AudioStream = null
