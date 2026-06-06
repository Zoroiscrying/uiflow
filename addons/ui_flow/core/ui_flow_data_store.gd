## Base class for reactive data stores.
##
## Extend this class to create data containers that automatically notify UI
## when properties change. Define signals for each property and emit them in
## property setters.
##
## Example:
## [codeblock]
## class_name PlayerData extends UIFlowDataStore
##
## signal health_changed(value: float)
## signal gold_changed(value: int)
##
## var health: float = 100.0:
##     set(v):
##         health = clampf(v, 0.0, max_health)
##         health_changed.emit(health)
##
## var gold: int = 0:
##     set(v):
##         gold = maxi(v, 0)
##         gold_changed.emit(gold)
## [/codeblock]
class_name UIFlowDataStore extends Resource
