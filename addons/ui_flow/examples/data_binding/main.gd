## Example main script — demonstrates data binding with UIFlow.
extends Control

@export var player_data: PlayerData

func _ready() -> void:
	# Push HUD page with data binding
	var hud: HUDPage = UIFlow.push(HUDPage) as HUDPage
	hud.player_data = player_data

	# Simulate data changes with buttons
	$UI/DamageButton.pressed.connect(_on_damage)
	$UI/HealButton.pressed.connect(_on_heal)
	$UI/EarnButton.pressed.connect(_on_earn)

	# Initialize display
	$UI/InfoLabel.text = "Use buttons to change data. UI updates automatically."


func _on_damage() -> void:
	player_data.health -= 15.0


func _on_heal() -> void:
	player_data.health += 25.0


func _on_earn() -> void:
	player_data.gold += 50
