## Base class for all UIFlow pages.
## Extend this class on any Control node that acts as a full-screen or half-screen UI page.
##
## Implement the lifecycle callbacks to respond to navigation events:
## - [code]_on_enter(data)[/code]: Called when the page is pushed onto the stack.
## - [code]_on_exit()[/code]: Called when the page is removed from the stack (popped or replaced).
## - [code]_on_pause()[/code]: Called when another page is pushed on top of this one.
## - [code]_on_resume()[/code]: Called when the page above is popped and this page becomes active again.
class_name UIFlowPage extends Control

## Override: called when this page is pushed onto the navigation stack.
## [param data] is the dictionary passed via [code]UIFlow.push(MyPage, data)[/code].
func _on_enter(_data: Dictionary = {}) -> void:
	pass

## Override: called when this page is removed from the stack (pop or replace).
func _on_exit() -> void:
	pass

## Override: called when another page is pushed on top of this page.
func _on_pause() -> void:
	pass

## Override: called when the page above is popped and this page becomes visible again.
func _on_resume() -> void:
	pass
