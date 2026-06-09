## ItemData — resource definition for game items.
@tool
class_name ItemData extends Resource

## Item types.
enum Type { CONSUMABLE, WEAPON, ARMOR, ACCESSORY, MATERIAL, QUEST }

## Item rarity.
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

## Item name.
@export var item_name: String = ""

## Item description.
@export_multiline var description: String = ""

## Item type.
@export var type: Type = Type.CONSUMABLE

## Item rarity.
@export var rarity: Rarity = Rarity.COMMON

## Item icon texture.
@export var icon: Texture2D = null

## Stack size (1 = not stackable).
@export var stack_size: int = 1

## Sell price in gold.
@export var sell_price: int = 0

## Equipment slot (only for WEAPON/ARMOR/ACCESSORY).
@export var equip_slot: StringName = &""

## Stat bonuses when equipped.
@export_group("Stats")
@export var bonus_attack: int = 0
@export var bonus_defense: int = 0
@export var bonus_health: int = 0
@export var bonus_mana: int = 0

## Rarity color for UI display.
static func get_rarity_color(rarity: Rarity) -> Color:
	match rarity:
		Rarity.COMMON: return Color(0.7, 0.7, 0.7)
		Rarity.UNCOMMON: return Color(0.2, 0.8, 0.2)
		Rarity.RARE: return Color(0.3, 0.5, 0.9)
		Rarity.EPIC: return Color(0.7, 0.3, 0.9)
		Rarity.LEGENDARY: return Color(0.9, 0.7, 0.1)
		_: return Color.WHITE
