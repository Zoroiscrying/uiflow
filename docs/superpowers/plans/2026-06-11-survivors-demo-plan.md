# Survivors Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the ARPG demo into a Brotato/Vampire Survivors-style wave survival game that showcases all UIFlow capabilities.

**Architecture:** Multi-weapon parallel auto-attack system with XP-based leveling, wave-based progression, and 8 UI pages demonstrating UIFlow components, bindings, transitions, and navigation patterns.

**Tech Stack:** Godot 4.6, GDScript, UIFlow plugin, gdUnit4

**Spec:** `docs/superpowers/specs/2026-06-11-survivors-demo-design.md`

---

## File Map

### New Files
| File | Responsibility |
|---|---|
| `addons/ui_flow/examples/survivors/weapon_data.gd` | Weapon Resource definition |
| `addons/ui_flow/examples/survivors/weapon_manager.gd` | Auto-attack controller on player |
| `addons/ui_flow/examples/survivors/xp_gem.gd` | XP pickup with auto-attract |
| `addons/ui_flow/examples/survivors/level_up_page.gd` | Card selection UI |
| `addons/ui_flow/examples/survivors/shop_page.gd` | Wave shop UI |
| `addons/ui_flow/examples/survivors/wave_summary_page.gd` | Post-wave stats UI |
| `addons/ui_flow/examples/survivors/backpack_page.gd` | Weapon backpack UI |
| `addons/ui_flow/examples/survivors/equipment_page.gd` | Equipment UI |
| `addons/ui_flow/examples/survivors/pause_page.gd` | Pause menu UI |
| `addons/ui_flow/examples/survivors/game_over_page.gd` | Death screen UI |
| `UIScene/SurvivorsLevelUpPage.tscn` | Level-up scene |
| `UIScene/SurvivorsShopPage.tscn` | Shop scene |
| `UIScene/SurvivorsWaveSummaryPage.tscn` | Wave summary scene |
| `UIScene/SurvivorsBackpackPage.tscn` | Backpack scene |
| `UIScene/SurvivorsEquipmentPage.tscn` | Equipment scene |
| `UIScene/SurvivorsPausePage.tscn` | Pause scene |
| `UIScene/GameOverPage.tscn` | Game over scene |

### Modified Files
| File | Changes |
|---|---|
| `addons/ui_flow/examples/survivors/survivors_main.gd` | Full rewrite: wave manager, event bus, page orchestration |
| `addons/ui_flow/examples/survivors/hud_page.gd` | Rename class, add weapon slots, DataStyle, bind_list |
| `addons/ui_flow/examples/survivors/player_stats.gd` | Rename class, add weapon_slots support |
| `addons/ui_flow/examples/survivors/enemy_stats.gd` | Rename class |
| `addons/ui_flow/examples/survivors/inventory_data.gd` | No changes needed |
| `addons/ui_flow/examples/survivors/equipment_data.gd` | No changes needed |
| `addons/ui_flow/examples/survivors/scenes/survivors_enemy.gd` | Rename, add UIFlowWorldUI health bar |
| `addons/ui_flow/examples/scenes/player_character.gd` | Add WeaponManager integration |
| `UIScene/SurvivorsHUDPage.tscn` | Update scene for new layout |

### Deleted Files
| File | Reason |
|---|---|
| `addons/ui_flow/examples/arpg_hud/dialog_page_arpg.gd` | Dialog system removed |
| `addons/ui_flow/examples/arpg_hud/dialog_data.gd` | Dialog system removed |
| `addons/ui_flow/examples/arpg_hud/scenes/arpg_player.gd` | Duplicate player script |

### Renamed Files (via git mv)
| Old | New |
|---|---|
| `addons/ui_flow/examples/arpg_hud/` | `addons/ui_flow/examples/survivors/` |
| `UIScene/ARPGHUDPage.tscn` | `UIScene/SurvivorsHUDPage.tscn` |
| `UIScene/ARPGShopPage.tscn` | `UIScene/SurvivorsShopPage.tscn` |
| `UIScene/ARPGInventoryPage.tscn` | `UIScene/SurvivorsBackpackPage.tscn` |
| `UIScene/ARPGEquipmentPage.tscn` | `UIScene/SurvivorsEquipmentPage.tscn` |
| `UIScene/ARPGDialogPage.tscn` | (deleted) |

---

## Task 1: Rename ARPG → Survivors

**Files:**
- Rename: `addons/ui_flow/examples/arpg_hud/` → `addons/ui_flow/examples/survivors/`
- Rename: `UIScene/ARPG*.tscn` → `UIScene/Survivors*.tscn`
- Delete: `dialog_page_arpg.gd`, `dialog_data.gd`, `arpg_player.gd`

- [ ] **Step 1: Rename directory**

```bash
git mv addons/ui_flow/examples/arpg_hud addons/ui_flow/examples/survivors
```

- [ ] **Step 2: Rename scene files**

```bash
git mv UIScene/ARPGHUDPage.tscn UIScene/SurvivorsHUDPage.tscn
git mv UIScene/ARPGShopPage.tscn UIScene/SurvivorsShopPage.tscn
git mv UIScene/ARPGInventoryPage.tscn UIScene/SurvivorsBackpackPage.tscn
git mv UIScene/ARPGEquipmentPage.tscn UIScene/SurvivorsEquipmentPage.tscn
rm UIScene/ARPGDialogPage.tscn
```

- [ ] **Step 3: Delete dead code**

```bash
git rm addons/ui_flow/examples/survivors/dialog_page_arpg.gd
git rm addons/ui_flow/examples/survivors/dialog_data.gd
git rm addons/ui_flow/examples/survivors/scenes/arpg_player.gd
```

- [ ] **Step 4: Update class_names in scripts**

In `player_stats.gd`: `class_name ARPGPlayerStats` → `class_name SurvivorsPlayerStats`
In `enemy_stats.gd`: `class_name ARPGEnemyStats` → `class_name SurvivorsEnemyStats`
In `hud_page.gd`: `class_name ARPGHUDPage` → `class_name SurvivorsHUDPage`
In `shop_page.gd`: `class_name ARPGShopPage` → `class_name SurvivorsShopPage`
In `inventory_page.gd`: `class_name ARPGInventoryPage` → `class_name SurvivorsBackpackPage`
In `equipment_page.gd`: `class_name ARPGEquipmentPage` → `class_name SurvivorsEquipmentPage`

- [ ] **Step 5: Update all references across codebase**

Search for `ARPG` in all .gd and .tscn files and replace:
- `ARPGPlayerStats` → `SurvivorsPlayerStats`
- `ARPGEnemyStats` → `SurvivorsEnemyStats`
- `ARPGHUDPage` → `SurvivorsHUDPage`
- `ARPGShopPage` → `SurvivorsShopPage`
- `ARPGInventoryPage` → `SurvivorsBackpackPage`
- `ARPGEquipmentPage` → `SurvivorsEquipmentPage`

- [ ] **Step 6: Update scene script references**

In each renamed .tscn file, update the `[ext_resource]` path to point to the new `survivors/` directory.

- [ ] **Step 7: Run tests to verify rename**

```bash
addons\gdUnit4\runtest.cmd --godot_binary F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --add res://tests/unit/arpg
```

Expected: All tests pass (class_name changes don't break tests since they use the class directly).

- [ ] **Step 8: Rename test directory and files**

```bash
git mv tests/unit/arpg tests/unit/survivors
git mv tests/unit/survivors/test_arpg_player_stats.gd tests/unit/survivors/test_survivors_player_stats.gd
git mv tests/unit/survivors/test_arpg_enemy_stats.gd tests/unit/survivors/test_survivors_enemy_stats.gd
git mv tests/unit/survivors/test_arpg_item_data.gd tests/unit/survivors/test_weapon_data.gd
git mv tests/unit/survivors/test_arpg_inventory_data.gd tests/unit/survivors/test_inventory_data.gd
git mv tests/unit/survivors/test_arpg_equipment_data.gd tests/unit/survivors/test_equipment_data.gd
git mv tests/unit/survivors/test_arpg_dialog_data.gd tests/unit/survivors/test_dialog_data.gd
```

Update class_name references in each test file.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "refactor: rename ARPG → Survivors for demo redesign"
```

---

## Task 2: Data Stores — Player Stats & Weapon Data

**Files:**
- Modify: `addons/ui_flow/examples/survivors/player_stats.gd`
- Create: `addons/ui_flow/examples/survivors/weapon_data.gd`
- Modify: `tests/unit/survivors/test_survivors_player_stats.gd`
- Create: `tests/unit/survivors/test_weapon_data.gd`

- [ ] **Step 1: Write test for WeaponData**

Create `tests/unit/survivors/test_weapon_data.gd`:

```gdscript
## Tests for WeaponData — weapon resource definition.
extends GdUnitTestSuite

## Test: default values
func test_defaults() -> void:
	var weapon := WeaponData.new()
	assert_that(weapon.weapon_name).is_equal("")
	assert_that(weapon.description).is_equal("")
	assert_that(weapon.type).is_equal(WeaponData.Type.BULLET)
	assert_that(weapon.rarity).is_equal(WeaponData.Rarity.COMMON)
	assert_that(weapon.cooldown).is_equal(1.0)
	assert_that(weapon.damage).is_equal(10)
	assert_that(weapon.range).is_equal(10.0)
	assert_that(weapon.level).is_equal(1)

## Test: get_rarity_color
func test_rarity_colors() -> void:
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.COMMON)).is_equal(Color(0.7, 0.7, 0.7))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.UNCOMMON)).is_equal(Color(0.2, 0.8, 0.2))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.RARE)).is_equal(Color(0.3, 0.5, 0.9))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.EPIC)).is_equal(Color(0.7, 0.3, 0.9))
	assert_that(WeaponData.get_rarity_color(WeaponData.Rarity.LEGENDARY)).is_equal(Color(0.9, 0.7, 0.1))

## Test: type enum values are distinct
func test_type_values() -> void:
	assert_that(WeaponData.Type.BULLET).is_not_equal(WeaponData.Type.ARC)
	assert_that(WeaponData.Type.ARC).is_not_equal(WeaponData.Type.ORBIT)
	assert_that(WeaponData.Type.ORBIT).is_not_equal(WeaponData.Type.SWEEP)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `addons\gdUnit4\runtest.cmd --godot_binary F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --add res://tests/unit/survivors/test_weapon_data.gd`
Expected: FAIL — WeaponData class not found

- [ ] **Step 3: Create WeaponData**

Create `addons/ui_flow/examples/survivors/weapon_data.gd`:

```gdscript
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `addons\gdUnit4\runtest.cmd --godot_binary F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --add res://tests/unit/survivors/test_weapon_data.gd`
Expected: PASS

- [ ] **Step 5: Update SurvivorsPlayerStats — add weapon slots**

Modify `player_stats.gd` to add:

```gdscript
## Equipped weapons (max 4 by default).
signal weapons_changed()

var weapons: Array[WeaponData] = []
var max_weapon_slots: int = 4

func add_weapon(weapon: WeaponData) -> bool:
	if weapons.size() >= max_weapon_slots:
		return false
	weapons.append(weapon)
	weapons_changed.emit()
	return true

func remove_weapon(index: int) -> WeaponData:
	if index < 0 or index >= weapons.size():
		return null
	var weapon: WeaponData = weapons[index]
	weapons.remove_at(index)
	weapons_changed.emit()
	return weapon

func get_weapons() -> Array[WeaponData]:
	return weapons
```

- [ ] **Step 6: Add test for weapon slots**

Append to `test_survivors_player_stats.gd`:

```gdscript
## Test: add_weapon
func test_add_weapon() -> void:
	var weapon := WeaponData.new()
	weapon.weapon_name = "Pistol"
	var ok := _stats.add_weapon(weapon)
	assert_that(ok).is_true()
	assert_that(_stats.get_weapons()).has_size(1)

## Test: add_weapon fails when full
func test_add_weapon_full() -> void:
	for i in range(4):
		var w := WeaponData.new()
		w.weapon_name = "W%d" % i
		_stats.add_weapon(w)
	var extra := WeaponData.new()
	extra.weapon_name = "Extra"
	var ok := _stats.add_weapon(extra)
	assert_that(ok).is_false()
	assert_that(_stats.get_weapons()).has_size(4)

## Test: remove_weapon
func test_remove_weapon() -> void:
	var weapon := WeaponData.new()
	weapon.weapon_name = "Pistol"
	_stats.add_weapon(weapon)
	var removed := _stats.remove_weapon(0)
	assert_that(removed).is_same(weapon)
	assert_that(_stats.get_weapons()).has_size(0)

## Test: weapons_changed signal
func test_weapons_changed_signal() -> void:
	var fired := [false]
	_stats.weapons_changed.connect(func(): fired[0] = true)
	_stats.add_weapon(WeaponData.new())
	assert_that(fired[0]).is_true()
```

- [ ] **Step 7: Run all tests**

Run: `addons\gdUnit4\runtest.cmd --godot_binary F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --add res://tests/unit/survivors`
Expected: All pass

- [ ] **Step 8: Commit**

```bash
git add addons/ui_flow/examples/survivors/weapon_data.gd addons/ui_flow/examples/survivors/player_stats.gd tests/unit/survivors/test_weapon_data.gd tests/unit/survivors/test_survivors_player_stats.gd
git commit -m "feat: add WeaponData resource and weapon slots to player stats"
```

---

## Task 3: Weapon Manager

**Files:**
- Create: `addons/ui_flow/examples/survivors/weapon_manager.gd`
- Modify: `addons/ui_flow/examples/scenes/player_character.gd`

- [ ] **Step 1: Create WeaponManager**

Create `addons/ui_flow/examples/survivors/weapon_manager.gd`:

```gdscript
## WeaponManager — auto-attacks with all equipped weapons.
extends Node

var player_stats: SurvivorsPlayerStats
var _cooldowns: Dictionary = {}  # weapon_index -> float

func setup(stats: SurvivorsPlayerStats) -> void:
	player_stats = stats
	_cooldowns.clear()
	for i in range(stats.get_weapons().size()):
		_cooldowns[i] = 0.0
	stats.weapons_changed.connect(_on_weapons_changed)


func _on_weapons_changed() -> void:
	# Reset cooldowns for new weapon count
	_cooldowns.clear()
	for i in range(player_stats.get_weapons().size()):
		if not _cooldowns.has(i):
			_cooldowns[i] = 0.0


func update(delta: float, player_pos: Vector3) -> WeaponData:
	if player_stats == null:
		return null

	var weapons := player_stats.get_weapons()
	var fired_weapon: WeaponData = null

	for i in range(weapons.size()):
		var weapon: WeaponData = weapons[i]
		if weapon == null:
			continue

		_cooldowns[i] = maxf(_cooldowns.get(i, 0.0) - delta, 0.0)
		if _cooldowns[i] <= 0.0:
			# Check if enemy in range
			var target := _find_nearest_enemy(player_pos, weapon.range)
			if target:
				_cooldowns[i] = weapon.cooldown
				fired_weapon = weapon
				# Return the weapon that fired — caller handles damage/VFX
				return weapon

	return null


func _find_nearest_enemy(pos: Vector3, max_range: float) -> Node3D:
	var enemies := Engine.get_main_loop().current_scene.get_tree().get_nodes_in_group("enemies")
	var nearest: Node3D = null
	var nearest_dist := max_range

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var enemy_stats: SurvivorsEnemyStats = enemy.get("stats")
		if enemy_stats == null or not enemy_stats.is_alive():
			continue
		var dist := pos.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy

	return nearest
```

- [ ] **Step 2: Integrate WeaponManager into player_character.gd**

In `player_character.gd`, add:

```gdscript
var _weapon_manager: Node  # WeaponManager

func _ready() -> void:
	add_to_group("player")
	# WeaponManager will be set by survivors_main.gd
```

In `_physics_process`, replace the existing auto-shoot logic with:

```gdscript
# Weapon manager handles auto-attack
if _weapon_manager and _weapon_manager.has_method("update"):
	var fired_weapon = _weapon_manager.update(delta, global_position)
	if fired_weapon:
		var target = _weapon_manager._find_nearest_enemy(global_position, fired_weapon.range)
		if target:
			_shoot_at(target, fired_weapon)
```

Replace `_shoot()` with `_shoot_at(target, weapon)`:

```gdscript
func _shoot_at(target: Node3D, weapon: WeaponData) -> void:
	var attack_power := weapon.damage
	if stats:
		attack_power += stats.attack

	var gun_pos: Vector3 = _gun_tip.global_position if _gun_tip else global_position + Vector3(0, 1, 0)
	var target_pos: Vector3 = target.global_position + Vector3(0, 0.8, 0)
	var shoot_dir: Vector3 = (target_pos - gun_pos).normalized()

	_spawn_muzzle_flash(gun_pos, shoot_dir)

	var enemy_stats: SurvivorsEnemyStats = target.get("stats")
	if enemy_stats and enemy_stats.is_alive():
		target.take_damage(attack_power)
		var kb_dir: Vector3 = (target.global_position - global_position).normalized()
		if target is CharacterBody3D:
			target.velocity = kb_dir * KNOCKBACK_FORCE
		var hud := UIFlow.get_page(SurvivorsHUDPage) as SurvivorsHUDPage
		if hud:
			hud.show_damage_number(attack_power, target.global_position + Vector3(0, 2, 0))

	_spawn_bullet_trail(gun_pos, target_pos)
```

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/examples/survivors/weapon_manager.gd addons/ui_flow/examples/scenes/player_character.gd
git commit -m "feat: add WeaponManager for multi-weapon auto-attack"
```

---

## Task 4: XP Gems & Event Bus

**Files:**
- Create: `addons/ui_flow/examples/survivors/xp_gem.gd`
- Create: `addons/ui_flow/examples/survivors/event_bus.gd` (UIFlowEventBus subclass)

- [ ] **Step 1: Create EventBus**

Create `addons/ui_flow/examples/survivors/event_bus.gd`:

```gdscript
## SurvivorsEventBus — game-wide decoupled communication.
class_name SurvivorsEventBus extends UIFlowEventBus

signal enemy_killed(enemy_name: String, xp: int, gold: int)
signal xp_gained(amount: float)
signal level_up(new_level: int)
signal wave_started(wave: int)
signal wave_ended(wave: int)
signal gold_changed(amount: int)
signal weapon_acquired(weapon: WeaponData)
```

- [ ] **Step 2: Create XP Gem**

Create `addons/ui_flow/examples/survivors/xp_gem.gd`:

```gdscript
## XpGem — collectible XP pickup with auto-attract to player.
extends Area3D

var xp_amount: float = 10.0
var _attracted: bool = false
var _player: Node3D = null
const ATTRACT_RANGE := 3.0
const COLLECT_RANGE := 0.5
const MOVE_SPEED := 8.0


func _ready() -> void:
	# Visual: small green glowing sphere
	var mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	mesh.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = Color(0.2, 1.0, 0.3)
	mat.emission_energy_multiplier = 3.0
	mat.albedo_color = Color(0.2, 1.0, 0.3)
	mesh.material_override = mat
	add_child(mesh)

	# Collision
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.3
	collision.shape = shape
	add_child(collision)

	# Find player
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return

	var dist := global_position.distance_to(_player.global_position)

	if dist < COLLECT_RANGE:
		_collect()
		return

	if dist < ATTRACT_RANGE:
		_attracted = true

	if _attracted:
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * MOVE_SPEED * delta


func _collect() -> void:
	var event_bus := _get_event_bus()
	if event_bus:
		event_bus.xp_gained.emit(xp_amount)
	queue_free()


func _get_event_bus() -> SurvivorsEventBus:
	# Get from autoload or scene
	var root := get_tree().current_scene
	if root and root.has_method("get_event_bus"):
		return root.get_event_bus()
	return null
```

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/examples/survivors/event_bus.gd addons/ui_flow/examples/survivors/xp_gem.gd
git commit -m "feat: add EventBus and XP gem pickup"
```

---

## Task 5: SurvivorsHUDPage

**Files:**
- Modify: `addons/ui_flow/examples/survivors/hud_page.gd`
- Modify: `UIScene/SurvivorsHUDPage.tscn`

- [ ] **Step 1: Update HUD script**

Rewrite `hud_page.gd` with new bindings:

```gdscript
## SurvivorsHUDPage — game HUD with UIFlow bindings showcase.
class_name SurvivorsHUDPage extends UIFlowPage

@export var player_stats: SurvivorsPlayerStats

@onready var _health_bar: ProgressBar = $HUD/Margin/VBox/HealthRow/HealthBar
@onready var _health_label: Label = $HUD/Margin/VBox/HealthRow/HealthLabel
@onready var _xp_bar: ProgressBar = $HUD/Margin/VBox/XPBar
@onready var _level_label: Label = $HUD/Margin/VBox/LevelLabel
@onready var _gold_label: Label = $HUD/Margin/VBox/GoldLabel
@onready var _wave_label: Label = $HUD/Margin/VBox/WaveLabel
@onready var _weapon_slots: HBoxContainer = $HUD/Margin/VBox/WeaponSlots

var _bindings: Array[UIFlowBindUtils.UIFlowBinding] = []
var _damage_overlay: ColorRect
var _shake_tween: Tween


func shake_camera(duration: float = 0.2, intensity: float = 6.0) -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	var original_pos: Vector2 = position
	_shake_tween = create_tween()
	var steps := 4
	for i in range(steps):
		var offset := Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		) * (1.0 - float(i) / steps)
		_shake_tween.tween_property(self, "position", original_pos + offset, duration / steps)
	_shake_tween.tween_property(self, "position", original_pos, duration / steps)


func _on_opened(_data: Variant = null) -> void:
	if player_stats == null and _data is Dictionary:
		player_stats = _data.get("player_stats", null)
	if player_stats == null:
		return

	for b in _bindings:
		b.unbind()
	_bindings.clear()

	# Health — bind_signal for bar, bind_signal_t for label
	_bindings.append(UIFlow.bind_signal(_health_bar, "value", player_stats.health_changed))
	_bindings.append(UIFlow.bind_signal_t(_health_label, "text", player_stats.health_changed,
		func(v): return "%d / %d" % [int(v), int(player_stats.max_health)]))

	# UIFlowDataStyle: pulse when health < 25%
	var health_style := UIFlowDataStyle.new()
	health_style.add_rule(func(v): return v < player_stats.max_health * 0.25, {"pulse": true})
	health_style.bind_signal(player_stats.health_changed)
	_health_bar.add_child(health_style)

	# XP
	_bindings.append(UIFlow.bind_signal(_xp_bar, "value", player_stats.xp_changed))

	# Level
	_bindings.append(UIFlow.bind_signal_t(_level_label, "text", player_stats.level_changed,
		func(v): return "Lv. %d" % v))

	# Gold
	_bindings.append(UIFlow.bind_signal_t(_gold_label, "text", player_stats.gold_changed,
		func(v): return "%d G" % v))

	# Weapon slots — bind_list
	UIFlow.bind_list(_weapon_slots, player_stats.weapons_changed,
		preload("res://addons/ui_flow/examples/survivors/weapon_slot_icon.tscn"),
		func(slot, weapon, index):
			slot.get_node("Icon").texture = weapon.icon if weapon else null
			UIFlowTooltip.attach(slot, weapon.weapon_name if weapon else "Empty")
	)

	# Initialize display
	_health_bar.max_value = player_stats.max_health
	_health_bar.value = player_stats.health
	_xp_bar.max_value = player_stats.xp_to_next
	_xp_bar.value = player_stats.xp


func _on_closed() -> void:
	for b in _bindings:
		b.unbind()
	_bindings.clear()


func show_damage_flash() -> void:
	if _damage_overlay == null:
		_damage_overlay = ColorRect.new()
		_damage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		_damage_overlay.color = Color(1, 0, 0, 0.3)
		_damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_damage_overlay)
	_damage_overlay.modulate.a = 0.4
	var tween: Tween = create_tween()
	tween.tween_property(_damage_overlay, "modulate:a", 0.0, 0.5)


func show_wave_start(wave: int) -> void:
	_wave_label.text = "Wave %d" % wave
	_wave_label.visible = true
	_wave_label.modulate.a = 1.0
	UIFlowUI.Toast.show_toast("Wave %d incoming!" % wave, "warning", 2.0)
	var tween: Tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(_wave_label, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): _wave_label.visible = false)


func show_damage_number(amount: int, world_pos: Vector3) -> void:
	var label := Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	var camera := get_viewport().get_camera_3d()
	if camera:
		var screen_pos := camera.unproject_position(world_pos)
		label.position = screen_pos - Vector2(20, 40)
	var container := get_parent()
	if container:
		container.add_child(label)
	else:
		add_child(label)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.finished.connect(label.queue_free)
```

- [ ] **Step 2: Update HUD scene**

Add `WeaponSlots` HBoxContainer to the HUD scene under `HUD/Margin/VBox/`.

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/examples/survivors/hud_page.gd UIScene/SurvivorsHUDPage.tscn
git commit -m "feat: update HUD with weapon slots, DataStyle, bind_list"
```

---

## Task 6: SurvivorsLevelUpPage

**Files:**
- Create: `addons/ui_flow/examples/survivors/level_up_page.gd`
- Create: `UIScene/SurvivorsLevelUpPage.tscn`

- [ ] **Step 1: Create scene**

Create `UIScene/SurvivorsLevelUpPage.tscn`:
- Root: Control (full rect, script: level_up_page.gd)
- Dimmer: ColorRect (full rect, black 0.5 alpha)
- VBox center: Title "Level Up!" + HBoxContainer for 3 cards
- Each card: PanelContainer with VBox (Icon + Name + Description + RarityLabel)

- [ ] **Step 2: Create script**

Create `addons/ui_flow/examples/survivors/level_up_page.gd`:

```gdscript
## SurvivorsLevelUpPage — card selection on level up.
class_name SurvivorsLevelUpPage extends UIFlowPage

@onready var _card_container: HBoxContainer = $VBox/CardContainer

var _cards: Array[WeaponData] = []
var _on_selected: Callable


func _ready() -> void:
	is_modal = true


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		_cards = data.get("cards", [])
		_on_selected = data.get("on_selected", Callable())
	_build_cards()
	# Stagger fade in
	UIFlow.anim_stagger_fade(_card_container)


func _build_cards() -> void:
	UIFlowUtils.clear_children(_card_container)
	for i in range(_cards.size()):
		var weapon: WeaponData = _cards[i]
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(180, 240)

		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 8)

		var icon := TextureRect.new()
		icon.texture = weapon.icon
		icon.custom_minimum_size = Vector2(64, 64)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(icon)

		var name_label := Label.new()
		name_label.text = weapon.weapon_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_color_override("font_color", WeaponData.get_rarity_color(weapon.rarity))
		vbox.add_child(name_label)

		var desc_label := Label.new()
		desc_label.text = weapon.description
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(desc_label)

		var stats_label := Label.new_text()
		stats_label.text = "DMG: %d | CD: %.1fs | RNG: %.0f" % [weapon.damage, weapon.cooldown, weapon.range]
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_label.add_theme_font_size_override("font_size", 12)
		vbox.add_child(stats_label)

		card.add_child(vbox)
		_card_container.add_child(card)

		# Tooltip
		UIFlowTooltip.attach(card, "%s\n%s\nDMG: %d | CD: %.1fs" % [weapon.weapon_name, weapon.description, weapon.damage, weapon.cooldown])

		# Click handler
		var idx := i
		card.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select_card(idx)
		)

		# Hover animation
		card.mouse_entered.connect(func(): UIFlow.anim_hover_enter(card))
		card.mouse_exited.connect(func(): UIFlow.anim_hover_exit(card))


func _select_card(index: int) -> void:
	if _on_selected.is_valid():
		_on_selected.call(_cards[index])
	UIFlow.pop()
```

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/examples/survivors/level_up_page.gd UIScene/SurvivorsLevelUpPage.tscn
git commit -m "feat: add level-up card selection page with stagger animation"
```

---

## Task 7: SurvivorsShopPage

**Files:**
- Create: `addons/ui_flow/examples/survivors/shop_page.gd`
- Create: `UIScene/SurvivorsShopPage.tscn`

- [ ] **Step 1: Create scene**

Create `UIScene/SurvivorsShopPage.tscn`:
- Root: Control (full rect, modal)
- Dimmer: ColorRect
- Panel: Header (Title + Gold + Close) + ScrollContainer with VBoxItemList + ConfirmPanel

- [ ] **Step 2: Create script**

Create `addons/ui_flow/examples/survivors/shop_page.gd`:

```gdscript
## SurvivorsShopPage — wave shop with UIFlowVirtualList and hover hints.
class_name SurvivorsShopPage extends UIFlowPage

@onready var _gold_label: Label = $Panel/VBox/Header/GoldLabel
@onready var _close_button: Button = $Panel/VBox/Header/CloseButton
@onready var _item_list: VBoxContainer = $Panel/VBox/ScrollContainer/ItemList
@onready var _confirm_panel: PanelContainer = $ConfirmPanel

var _player_stats: SurvivorsPlayerStats
var _shop_items: Array = []
var _selected_item = null


func _ready() -> void:
	is_modal = true
	_close_button.pressed.connect(func(): UIFlow.pop())
	_confirm_panel.visible = false


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		_player_stats = data.get("player_stats", null)
		_shop_items = data.get("items", [])
		if data.has("inventory_data"):
			pass  # store reference if needed
	_rebuild_shop_list()
	_update_gold_display()


func _rebuild_shop_list() -> void:
	UIFlowUtils.clear_children(_item_list)
	for item in _shop_items:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var icon := TextureRect.new()
		if item is WeaponData:
			icon.texture = item.icon
		icon.custom_minimum_size = Vector2(32, 32)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label := Label.new()
		if item is WeaponData:
			name_label.text = item.weapon_name
			name_label.add_theme_color_override("font_color", WeaponData.get_rarity_color(item.rarity))
		info.add_child(name_label)
		var desc_label := Label.new()
		if item is WeaponData:
			desc_label.text = item.description
		desc_label.add_theme_font_size_override("font_size", 11)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(desc_label)
		row.add_child(info)

		var price_label := Label.new()
		if item is WeaponData:
			price_label.text = "%d G" % item.sell_price
		row.add_child(price_label)

		var buy_btn := Button.new()
		buy_btn.text = "Buy"
		buy_btn.custom_minimum_size = Vector2(60, 32)
		var shop_item = item
		buy_btn.pressed.connect(func(): _on_buy_pressed(shop_item))
		row.add_child(buy_btn)

		_item_list.add_child(row)

		# Hover hint with BBCode
		UIFlowHoverHint.attach(row, "[b]%s[/b]\n%s" % [
			item.weapon_name if item is WeaponData else "Item",
			item.description if item is WeaponData else ""
		], true)

	# Stagger fade in
	UIFlow.anim_stagger_fade(_item_list)


func _on_buy_pressed(item) -> void:
	_selected_item = item
	var price: int = item.sell_price if item is WeaponData else 0
	_confirm_panel.visible = true


func _update_gold_display() -> void:
	if _player_stats:
		_gold_label.text = "%d G" % _player_stats.gold


func _on_back() -> void:
	if _confirm_panel.visible:
		_confirm_panel.visible = false
		_selected_item = null
	else:
		UIFlow.pop()
```

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/examples/survivors/shop_page.gd UIScene/SurvivorsShopPage.tscn
git commit -m "feat: add shop page with hover hints and stagger animation"
```

---

## Task 8: SurvivorsWaveSummaryPage

**Files:**
- Create: `addons/ui_flow/examples/survivors/wave_summary_page.gd`
- Create: `UIScene/SurvivorsWaveSummaryPage.tscn`

- [ ] **Step 1: Create script**

Create `addons/ui_flow/examples/survivors/wave_summary_page.gd`:

```gdscript
## SurvivorsWaveSummaryPage — post-wave statistics with UIFlowDataGrid.
class_name SurvivorsWaveSummaryPage extends UIFlowPage

@onready var _title_label: Label = $VBox/TitleLabel
@onready var _stats_grid: UIFlowDataGrid = $VBox/StatsGrid
@onready var _shop_button: Button = $VBox/Buttons/ShopButton
@onready var _skip_button: Button = $VBox/Buttons/SkipButton

var _wave: int = 0
var _on_shop: Callable
var _on_skip: Callable


func _ready() -> void:
	is_modal = true
	_shop_button.pressed.connect(func():
		if _on_shop.is_valid(): _on_shop.call()
	)
	_skip_button.pressed.connect(func():
		if _on_skip.is_valid(): _on_skip.call()
	)


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		_wave = data.get("wave", 0)
		_on_shop = data.get("on_shop", Callable())
		_on_skip = data.get("on_skip", Callable())
		var kills: Dictionary = data.get("kills", {})
		_setup_grid(kills)

	_title_label.text = "Wave %d Complete!" % _wave


func _setup_grid(kills: Dictionary) -> void:
	_stats_grid.add_column("Enemy", 150, false)
	_stats_grid.add_column("Killed", 80, true)
	_stats_grid.add_column("XP", 80, true)
	_stats_grid.add_column("Gold", 80, true)

	var grid_data: Array = []
	for enemy_name in kills:
		var info: Dictionary = kills[enemy_name]
		grid_data.append({
			"Enemy": enemy_name,
			"Killed": str(info.get("count", 0)),
			"XP": str(info.get("xp", 0)),
			"Gold": str(info.get("gold", 0)),
		})
	_stats_grid.set_data(grid_data)
```

- [ ] **Step 2: Commit**

```bash
git add addons/ui_flow/examples/survivors/wave_summary_page.gd UIScene/SurvivorsWaveSummaryPage.tscn
git commit -m "feat: add wave summary page with DataGrid"
```

---

## Task 9: SurvivorsBackpackPage & SurvivorsEquipmentPage

**Files:**
- Modify: `addons/ui_flow/examples/survivors/inventory_page.gd`
- Modify: `addons/ui_flow/examples/survivors/equipment_page.gd`
- Modify: `UIScene/SurvivorsBackpackPage.tscn`
- Modify: `UIScene/SurvivorsEquipmentPage.tscn`

- [ ] **Step 1: Update backpack page**

Rename class to `SurvivorsBackpackPage`. Add UIFlowTooltip to each slot, add UIFlowContextMenu for right-click actions (upgrade/sell/drop).

- [ ] **Step 2: Update equipment page**

Rename class to `SurvivorsEquipmentPage`. Add UIFlowDataStyle for stat bonus coloring, UIFlowHoverHint for equipped items.

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/examples/survivors/inventory_page.gd addons/ui_flow/examples/survivors/equipment_page.gd UIScene/SurvivorsBackpackPage.tscn UIScene/SurvivorsEquipmentPage.tscn
git commit -m "feat: update backpack and equipment pages with tooltips and context menu"
```

---

## Task 10: SurvivorsPausePage & GameOverPage

**Files:**
- Create: `addons/ui_flow/examples/survivors/pause_page.gd`
- Create: `addons/ui_flow/examples/survivors/game_over_page.gd`
- Create: `UIScene/SurvivorsPausePage.tscn`
- Create: `UIScene/GameOverPage.tscn`

- [ ] **Step 1: Create pause page**

Create `pause_page.gd`:

```gdscript
## SurvivorsPausePage — pause menu with resume and quit.
class_name SurvivorsPausePage extends UIFlowPage

@onready var _resume_button: Button = $VBox/ResumeButton
@onready var _quit_button: Button = $VBox/QuitButton


func _ready() -> void:
	is_modal = true
	_resume_button.pressed.connect(func(): UIFlow.pop())
	_quit_button.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Quit?", "Return to main menu?", func():
			get_tree().paused = false
			UIFlow.pop_to_root()
		)
	)


func _on_opened(_data: Variant = null) -> void:
	get_tree().paused = true
	UIFlow.set_default_focus(_resume_button)


func _on_closed() -> void:
	get_tree().paused = false
```

- [ ] **Step 2: Create game over page**

Create `game_over_page.gd`:

```gdscript
## GameOverPage — death screen with restart options.
class_name GameOverPage extends UIFlowPage

@onready var _restart_button: Button = $VBox/RestartButton
@onready var _menu_button: Button = $VBox/MenuButton
@onready var _stats_grid: UIFlowDataGrid = $VBox/StatsGrid


func _ready() -> void:
	is_modal = true
	_restart_button.pressed.connect(func(): UIFlow.pop_to_root())
	_menu_button.pressed.connect(func():
		UIFlowUI.Confirm.show_confirm("Quit?", "Return to main menu?", func():
			UIFlow.pop_to_root()
		)
	)


func _on_opened(data: Variant = null) -> void:
	if data is Dictionary:
		var stats: Dictionary = data.get("stats", {})
		_setup_stats(stats)
	UIFlow.set_default_focus(_restart_button)


func _setup_stats(stats: Dictionary) -> void:
	_stats_grid.add_column("Stat", 150, false)
	_stats_grid.add_column("Value", 100, false)
	var grid_data: Array = []
	for key in stats:
		grid_data.append({"Stat": key, "Value": str(stats[key])})
	_stats_grid.set_data(grid_data)
```

- [ ] **Step 3: Commit**

```bash
git add addons/ui_flow/examples/survivors/pause_page.gd addons/ui_flow/examples/survivors/game_over_page.gd UIScene/SurvivorsPausePage.tscn UIScene/GameOverPage.tscn
git commit -m "feat: add pause and game over pages"
```

---

## Task 11: Survivors Main Controller

**Files:**
- Rewrite: `addons/ui_flow/examples/survivors/survivors_main.gd`
- Modify: `project.godot` (autoload EventBus)

- [ ] **Step 1: Add EventBus to autoloads**

In `project.godot`, add:
```
SurvivorsEventBus="*res://addons/ui_flow/examples/survivors/event_bus.gd"
```

- [ ] **Step 2: Rewrite main controller**

Rewrite `survivors_main.gd` with full wave management, page orchestration, and event bus integration. Key responsibilities:
- Wave lifecycle: start wave → spawn enemies → detect completion → summary → shop → next wave
- Level-up detection: when XP threshold reached, push level-up page
- Gold management: award gold on enemy kill and wave completion
- Input handling: I=Backpack, P=Equipment, Escape=Pause
- Navigation guards: block shop during active wave
- UIFlowWorldUI: enemy health bars

- [ ] **Step 3: Update player_character.gd**

Wire WeaponManager setup from main controller.

- [ ] **Step 4: Commit**

```bash
git add addons/ui_flow/examples/survivors/survivors_main.gd addons/ui_flow/examples/scenes/player_character.gd project.godot
git commit -m "feat: rewrite main controller with wave management and page orchestration"
```

---

## Task 12: SurvivorsEnemy with UIFlowWorldUI

**Files:**
- Modify: `addons/ui_flow/examples/survivors/scenes/arpg_enemy.gd` → rename to `survivors_enemy.gd`

- [ ] **Step 1: Replace SubViewport health bar with UIFlowWorldUI**

Remove the SubViewport + Sprite3D health bar code. Add UIFlowWorldUI child that projects a ProgressBar to screen space.

- [ ] **Step 2: Commit**

```bash
git add addons/ui_flow/examples/survivors/scenes/survivors_enemy.gd
git commit -m "feat: replace SubViewport health bar with UIFlowWorldUI"
```

---

## Task 13: Unit Tests

**Files:**
- Create: `tests/unit/survivors/test_survivors_main.gd`

- [ ] **Step 1: Write wave manager tests**

Test wave progression, enemy count scaling, intermission logic.

- [ ] **Step 2: Write weapon manager tests**

Test cooldown tracking, nearest enemy detection, weapon firing.

- [ ] **Step 3: Run full test suite**

Run: `addons\gdUnit4\runtest.cmd --godot_binary F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64.exe --add res://tests/unit/survivors`
Expected: All pass

- [ ] **Step 4: Commit**

```bash
git add tests/unit/survivors/
git commit -m "test: add unit tests for survivors demo"
```

---

## Task 14: Integration & Polish

- [ ] **Step 1: Wire all pages in survivors_main.gd**

Ensure the full flow works:
- Game start → HUD
- Wave start → enemies spawn → auto-attack
- Enemy die → XP gem → collect → level up → card select
- Wave end → summary → shop → next wave
- Escape → pause
- Death → game over

- [ ] **Step 2: Verify all UIFlow features demonstrated**

Checklist:
- [ ] UIFlowTooltip on weapon slots and shop items
- [ ] UIFlowHoverHint on shop items (BBCode)
- [ ] UIFlowDataGrid on wave summary and game over
- [ ] UIFlowDataStyle on health bar (pulse at low HP)
- [ ] UIFlowWorldUI on enemy health bars
- [ ] bind_visible on wave indicator
- [ ] bind_list on weapon slots
- [ ] UIFlowEventBus for game events
- [ ] UIInputActionNode for I/P/Escape
- [ ] UIFlow.replace() for summary → shop
- [ ] UIFlow.pop_to_root() for restart
- [ ] UIFlowSequencedEffect on level-up cards
- [ ] stagger_fade_in on shop items and cards
- [ ] UIFlowConfirmDialog on quit
- [ ] UIFlowContextMenu on weapon slots
- [ ] Navigation guard on shop
- [ ] Modal vs non-modal coexistence

- [ ] **Step 3: Run full test suite**

Expected: All pass

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: survivors demo complete — UIFlow capability showcase"
```
