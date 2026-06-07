## Base class for all UIFlow pages.
## Extend this class on any Control node that acts as a UI page.
##
## Lifecycle:
## 1. [code]_on_created(data)[/code] — Page instantiated (once)
## 2. [code]_on_opened(data)[/code] — Page pushed onto stack
## 3. [code]_on_hidden()[/code] — Another page pushed on top
## 4. [code]_on_shown()[/code] — Page above popped, this page visible again
## 5. [code]_on_closed()[/code] — Page removed from stack
## 6. [code]_on_destroyed()[/code] — Page about to be freed
class_name UIFlowPage extends Control

## If true, this page intercepts all input. Lower pages don't receive back/cancel.
## Set to true for modal dialogs (pause menu, confirm dialog, etc.)
@export var is_modal: bool = false

## Override: called once when the page is first instantiated.
func _on_created(_data: Dictionary = {}) -> void:
	pass

## Override: called when this page is pushed onto the navigation stack.
func _on_opened(_data: Dictionary = {}) -> void:
	pass

## Override: called when another page is pushed on top of this page.
func _on_hidden() -> void:
	pass

## Override: called when the page above is popped and this page becomes visible again.
func _on_shown() -> void:
	pass

## Override: called when this page is removed from the stack (popped or replaced).
func _on_closed() -> void:
	pass

## Override: called when the page is about to be freed (dispose).
func _on_destroyed() -> void:
	pass
