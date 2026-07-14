class_name ItemData extends Resource

enum Type { WEAPON, ARMOR, ACCESSORY, CONSUMABLE }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC }

## Note: fields are @export so Resource.duplicate() copies them
## (plain script vars are not serialized and would be lost on duplicate).
@export var item_name: String = ""
@export var description: String = ""
@export var type: Type = Type.WEAPON
@export var rarity: Rarity = Rarity.COMMON
@export var sell_price: int = 0
@export var equip_slot: StringName = &""
@export var bonus_attack: int = 0
@export var bonus_defense: int = 0
@export var bonus_health: int = 0
@export var bonus_mana: int = 0
@export var icon: Texture2D = null

static func get_rarity_color(rarity: Rarity) -> Color:
	match rarity:
		Rarity.COMMON: return Color(0.7, 0.7, 0.7)
		Rarity.UNCOMMON: return Color(0.3, 0.8, 0.4)
		Rarity.RARE: return Color(0.3, 0.5, 0.9)
		Rarity.EPIC: return Color(0.9, 0.6, 0.2)
		_: return Color.WHITE
