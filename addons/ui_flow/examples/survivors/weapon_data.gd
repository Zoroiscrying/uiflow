## WeaponData — resource definition for weapons.
@tool
class_name WeaponData extends Resource


## Projectile types.
enum Type { BULLET, ARC, ORBIT, SWEEP }


## Weapon rarity.
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }


## Weapon name.
@export var weapon_name: String = ""

## Weapon description.
@export_multiline var description: String = ""

## Projectile type.
@export var type: Type = Type.BULLET

## Weapon rarity.
@export var rarity: Rarity = Rarity.COMMON

## Weapon icon texture.
@export var icon: Texture2D = null

## Attack cooldown in seconds.
@export var cooldown: float = 1.0

## Damage per hit.
@export var damage: int = 10

## Attack range in meters.
@export var range: float = 10.0

## Weapon level (upgrades increase this).
@export var level: int = 1

## Sell price in gold.
@export var sell_price: int = 10


## Rarity color for UI display.
static func get_rarity_color(rarity: Rarity) -> Color:
	match rarity:
		Rarity.COMMON: return Color(0.7, 0.7, 0.7)
		Rarity.UNCOMMON: return Color(0.2, 0.8, 0.2)
		Rarity.RARE: return Color(0.3, 0.5, 0.9)
		Rarity.EPIC: return Color(0.7, 0.3, 0.9)
		Rarity.LEGENDARY: return Color(0.9, 0.7, 0.1)
		_: return Color.WHITE
