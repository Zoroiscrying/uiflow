# Survivors Demo — UIFlow Capability Showcase

**Date**: 2026-06-11
**Status**: Draft
**Scope**: Full redesign of ARPG demo → Survivors demo, showcasing all UIFlow capabilities

---

## 1. Goal

Redesign the existing ARPG HUD demo into a Brotato/Vampire Survivors-style wave survival game. The primary purpose is to **showcase every UIFlow component, binding, transition, and pattern** in a real gameplay context.

Secondary goals:
- Demonstrate reactive data stores driving UI in real-time
- Show modal vs non-modal page coexistence on the navigation stack
- Provide a reference implementation for UIFlow consumers

## 2. Core Gameplay

### 2.1 Player
- Top-down 3D view, WASD movement
- Auto-attacks nearest enemy with equipped weapons
- No manual aiming — weapons fire independently

### 2.2 Weapons (Multi-Weapon Parallel)
- Player has N weapon slots (default 4)
- Each weapon is a `WeaponData` Resource: name, cooldown, damage, range, projectile type
- `WeaponManager` on player iterates equipped weapons, auto-fires at nearest enemy
- Projectile types: bullet, arc, orbit, melee sweep

### 2.3 Waves (Brotato Style)
- Explicit waves with intermission between them
- Wave N spawns `3 + N*2` enemies
- Between waves: wave summary → shop → next wave
- Intermission duration: player-controlled (advance when ready)

### 2.4 XP & Leveling
- Enemies drop XP gems on death (GPUParticles3D)
- XP accumulates → level up → card selection (3 random weapons/items)
- Level-up pauses the game (modal page)

### 2.5 Economy
- Gold earned from killing enemies and wave completion
- Gold spent in wave shop between waves
- Items: weapons, stat boosters, consumables

### 2.6 Death
- Player death → Game Over page
- Options: restart (pop_to_root) or return to main menu

## 3. UIFlow Features Demonstrated

### 3.1 Components

| Component | Demo Location | Usage |
|---|---|---|
| UIFlowTooltip | HUD weapon slots, shop items, cards | Hover to show weapon stats |
| UIFlowHoverHint | Shop items | BBCode detailed description |
| UIFlowDataGrid | Wave summary page | Kill statistics table with sortable columns |
| UIFlowDataStyle | HUD health bar | Pulse effect when health < 25% |
| UIFlowWorldUI | Enemy health bars | 3D-to-screen projection (replaces SubViewport hack) |
| UIFlowConfirmDialog | Pause page, game over | "Return to main menu" confirmation |
| UIFlowContextMenu | Backpack weapon slots | Right-click: upgrade / sell / drop |
| UIFlowVirtualList | Shop page | Virtual scrolling for large item lists |
| UIFlowInventoryGrid | Backpack page | Grid layout with drag-drop |
| UIFlowItemSlot | Backpack + equipment pages | Drag-drop equip/unequip with type filtering |
| UIFlowDragDrop | Backpack ↔ equipment | Drag weapons between slots |
| UIFlowDropTarget | Equipment slots | Highlight on valid drop |

### 3.2 Bindings

| Binding | Demo Location | Usage |
|---|---|---|
| bind_signal | HUD health/mana/xp bars | Signal value → ProgressBar.value |
| bind_signal_t | HUD gold, level label | Signal value → transform → label text |
| bind_visible | HUD wave indicator | Show during wave, hide during intermission |
| bind_multi | HUD DPS display | Multiple weapon signals → total DPS |
| bind_list | HUD weapon slots | Array of equipped weapons → slot UI instances |
| bind_format | HUD stats | Format string binding for stat display |
| bind_slider | Settings page (if retained) | Two-way slider binding |

### 3.3 Navigation

| Feature | Demo Location | Usage |
|---|---|---|
| push() | All pages | Standard page push |
| replace() | Wave summary → Shop | Replace without back navigation |
| pop_to_root() | Game over → restart | Clear stack back to HUD |
| get_page() | Player → HUD | Find HUD instance for damage flash |
| Navigation guards | Shop page | Block shop during active wave |
| Page lifecycle: _on_hidden | HUD | Pause wave timer when covered |
| Page lifecycle: _on_shown | HUD | Resume wave timer when uncovered |
| page_opened / page_closed signals | Main controller | Track navigation state |

### 3.4 Transitions & Animation

| Feature | Demo Location | Usage |
|---|---|---|
| UIFlowSequencedEffect | Level-up cards | scale_then_fade entry |
| UIFlowSlideEffect | Shop page | Slide up entry |
| UIFlowFadeEffect | Pause overlay | Fade in dark overlay |
| Per-page exit_transition | Level-up, shop, summary | Custom exit animations |
| stagger_fade_in | Shop items, level-up cards | Staggered list entry |
| anim_hover_enter/exit | Shop item buttons | Hover scale effect |
| anim_pulse | Low health indicator | Pulse animation |
| anim_shake | Damage feedback | Screen shake |

### 3.5 Events & Communication

| Feature | Demo Location | Usage |
|---|---|---|
| UIFlowEventBus | Game-wide | enemy_killed, xp_gained, level_up, wave_started, wave_ended, gold_changed |
| UIInputActionNode | Backpack/Equipment/Pause | Declare I, P, Escape as input actions |

### 3.6 Theming

| Feature | Demo Location | Usage |
|---|---|---|
| UIFlowTheme | All pages | Consistent dark theme |
| get_color / set_color | Rarity coloring | Item rarity → color slot mapping |

## 4. UI Pages (8 Total)

### 4.1 SurvivorsHUDPage (Non-Modal)

**Purpose**: Always-visible game state display.

**Layout**:
- Top-left: Health bar + value (bind_signal, UIFlowDataStyle for low HP pulse)
- Below: Mana bar + value (bind_signal)
- Below: XP bar + level label (bind_signal, bind_signal_t)
- Top-right: Gold (bind_signal_t)
- Center-top: Wave info (bind_visible: show during wave, hide during intermission)
- Bottom-left: Weapon slot icons (bind_list, UIFlowTooltip per slot)
- Bottom-center: Controls hint

**Lifecycle**:
- `_on_opened`: Setup all bindings, push HUD
- `_on_hidden`: Pause wave timer
- `_on_shown`: Resume wave timer
- `_on_closed`: Unbind all

**Scene**: `UIScene/SurvivorsHUDPage.tscn`
**Script**: `addons/ui_flow/examples/survivors/hud_page.gd`

### 4.2 SurvivorsLevelUpPage (Modal)

**Purpose**: Card selection on level-up. Game pauses.

**Layout**:
- Semi-transparent dark overlay
- Title: "Level Up!"
- 3 cards in a row, each with:
  - Icon, name, description, rarity border
  - UIFlowTooltip for detailed stats
  - Click to select
- Cards enter with stagger_fade_in + UIFlowSequencedEffect (scale_then_fade)

**Behavior**:
- Opened with data: `{"cards": [WeaponData, WeaponData, WeaponData]}`
- On card select: emit event via UIFlowEventBus, pop page
- Exit transition: UIFlowFadeEffect

**Scene**: `UIScene/SurvivorsLevelUpPage.tscn`
**Script**: `addons/ui_flow/examples/survivors/level_up_page.gd`

### 4.3 SurvivorsShopPage (Modal)

**Purpose**: Buy weapons/items between waves. Game pauses.

**Layout**:
- Header: "Shop" + gold display (bind_signal_t on gold)
- Item list: UIFlowVirtualList with UIFlowHoverHint per item
- Each row: icon + name + price + buy button
- Buy confirmation: UIFlowConfirmDialog
- Close button → pop → start next wave

**Behavior**:
- Opened with data: `{"items": Array[ItemData], "player_stats": SurvivorsPlayerStats}`
- Staggered entry animation for items
- Guard: cannot open during active wave
- Exit transition: UIFlowSlideEffect (slide down)

**Scene**: `UIScene/SurvivorsShopPage.tscn`
**Script**: `addons/ui_flow/examples/survivors/shop_page.gd`

### 4.4 SurvivorsWaveSummaryPage (Modal)

**Purpose**: Post-wave statistics. Transition to shop or next wave.

**Layout**:
- Title: "Wave X Complete!"
- UIFlowDataGrid: kill statistics (columns: Enemy Type, Count, XP Earned, Gold Earned)
- Total rewards summary
- Buttons: "Enter Shop" / "Skip to Next Wave"

**Behavior**:
- "Enter Shop" → replace(SurvivorsShopPage)
- "Skip" → pop → next wave starts
- Entry: UIFlowSequencedEffect (fade_then_scale)
- Exit: UIFlowFadeEffect

**Scene**: `UIScene/SurvivorsWaveSummaryPage.tscn`
**Script**: `addons/ui_flow/examples/survivors/wave_summary_page.gd`

### 4.5 SurvivorsBackpackPage (Non-Modal)

**Purpose**: Manage held weapons. Game continues running.

**Layout**:
- Header: "Backpack" + close button
- Equipped weapon slots (top): UIFlowItemSlot with UIFlowContextMenu (right-click: upgrade/sell/drop)
- Held weapons grid (bottom): UIFlowInventoryGrid with drag-drop
- UIFlowTooltip on each weapon slot

**Behavior**:
- Non-modal: player can still move, game continues
- Drag weapon from grid to equip slot
- Right-click context menu for actions
- Exit: close button or press I again

**Scene**: `UIScene/SurvivorsBackpackPage.tscn`
**Script**: `addons/ui_flow/examples/survivors/backpack_page.gd`

### 4.6 SurvivorsEquipmentPage (Non-Modal)

**Purpose**: Manage equipment slots. Game continues running.

**Layout**:
- Equipment slots: head, chest, hands, feet, accessory
- UIFlowItemSlot per slot with UIFlowTooltip
- Stat bonuses summary with UIFlowDataStyle (green for positive, red for negative)
- UIFlowHoverHint on equipped items (BBCode detail)

**Behavior**:
- Non-modal
- Drag-drop equip/unequip
- Stats update reactively via equipment_data.stats_changed

**Scene**: `UIScene/SurvivorsEquipmentPage.tscn`
**Script**: `addons/ui_flow/examples/survivors/equipment_page.gd`

### 4.7 SurvivorsPausePage (Modal)

**Purpose**: Pause game. Show resume/quit options.

**Layout**:
- Semi-transparent dark overlay (fade in)
- Center panel:
  - Title: "Paused"
  - "Resume" button → pop
  - "Return to Main Menu" button → UIFlowConfirmDialog → pop_to_root

**Behavior**:
- Triggered by Escape key (UIInputActionNode)
- Pauses game tree: `get_tree().paused = true`
- On resume: unpauses
- Entry: UIFlowFadeEffect (overlay)
- Exit: UIFlowFadeEffect

**Scene**: `UIScene/SurvivorsPausePage.tscn`
**Script**: `addons/ui_flow/examples/survivors/pause_page.gd`

### 4.8 GameOverPage (Modal)

**Purpose**: Death screen with stats and restart options.

**Layout**:
- Dark overlay
- Title: "Game Over"
- UIFlowDataGrid: final statistics (waves survived, total kills, gold earned, level reached)
- Buttons: "Restart" → pop_to_root / "Main Menu" → UIFlowConfirmDialog → pop_to_root

**Behavior**:
- Entry: UIFlowScaleEffect (scale_pop)
- Exit: UIFlowFadeEffect

**Scene**: `UIScene/GameOverPage.tscn`
**Script**: `addons/ui_flow/examples/survivors/game_over_page.gd`

## 5. Data Architecture

### 5.1 Data Stores (UIFlowDataStore)

| Store | Properties | Signals |
|---|---|---|
| SurvivorsPlayerStats | health, max_health, mana, max_mana, xp, xp_to_next, level, gold, attack | *_changed per property |
| SurvivorsEnemyStats | enemy_name, max_health, health, attack | health_changed, name_changed |
| WeaponData | weapon_name, description, icon, type, rarity, cooldown, damage, range, level | (static Resource, no signals) |
| InventoryData | slots, slot_count | items_changed, item_added, item_removed |
| EquipmentData | _slots | item_equipped, item_unequipped, stats_changed |

### 5.2 Event Bus Events

| Event | Emitter | Consumer |
|---|---|---|
| enemy_killed | Enemy _die() | Main (XP drop, gold, kill count) |
| xp_gained | Main | HUD (XP bar update) |
| level_up | Player stats | Main (show level-up page) |
| wave_started | Main | HUD (show wave indicator) |
| wave_ended | Main | HUD (hide wave indicator, show summary) |
| gold_changed | Player stats | HUD (gold display), Shop (buy check) |

### 5.3 File Structure

All scripts live in `addons/ui_flow/examples/survivors/`. Scene files live in `UIScene/`.

Class names use `Survivors*` prefix. File names use `snake_case` without prefix for brevity.

```
addons/ui_flow/examples/survivors/
├── survivors_main.gd              — Main game controller
├── hud_page.gd                    — HUD (class_name: SurvivorsHUDPage)
├── level_up_page.gd               — Level-up card selection (class_name: SurvivorsLevelUpPage)
├── shop_page.gd                   — Wave shop (class_name: SurvivorsShopPage)
├── wave_summary_page.gd           — Post-wave statistics (class_name: SurvivorsWaveSummaryPage)
├── backpack_page.gd               — Weapon backpack (class_name: SurvivorsBackpackPage)
├── equipment_page.gd              — Equipment (class_name: SurvivorsEquipmentPage)
├── pause_page.gd                  — Pause menu (class_name: SurvivorsPausePage)
├── game_over_page.gd              — Death screen (class_name: GameOverPage)
├── weapon_data.gd                 — Weapon Resource (class_name: WeaponData)
├── weapon_manager.gd              — Auto-attack controller
├── xp_gem.gd                      — XP pickup (GPUParticles3D-based)
├── player_stats.gd                — Player reactive data (class_name: SurvivorsPlayerStats)
├── enemy_stats.gd                 — Enemy reactive data (class_name: SurvivorsEnemyStats)
├── inventory_data.gd              — Inventory data (class_name: InventoryData)
├── equipment_data.gd              — Equipment data (class_name: EquipmentData)
├── scenes/
│   ├── survivors_enemy.gd         — Enemy AI
│   └── survivors_enemy.gd.uid
└── shaders/

UIScene/
├── SurvivorsHUDPage.tscn
├── SurvivorsLevelUpPage.tscn
├── SurvivorsShopPage.tscn
├── SurvivorsWaveSummaryPage.tscn
├── SurvivorsBackpackPage.tscn
├── SurvivorsEquipmentPage.tscn
├── SurvivorsPausePage.tscn
└── GameOverPage.tscn
```

### 5.4 UIFlowWorldUI (3D Scene Component)

Enemy health bars use `UIFlowWorldUI` to project a Control node to screen space, following each enemy's 3D position. This replaces the current SubViewport + Sprite3D approach. Implementation: add a UIFlowWorldUI child to each enemy, target = enemy node, with a ProgressBar as the projected content.

## 6. Renaming Plan

| Old | New |
|---|---|
| ARPGHUDPage | SurvivorsHUDPage |
| ARPGShopPage | SurvivorsShopPage |
| ARPGInventoryPage → SurvivorsBackpackPage |
| ARPGEquipmentPage | SurvivorsEquipmentPage |
| ARPGDialogPage | (deleted) |
| ARPGPlayerStats | SurvivorsPlayerStats |
| ARPGEnemyStats | SurvivorsEnemyStats |
| arpg_hud/ | survivors/ |
| arpg_main.gd | survivors_main.gd |
| arpg_enemy.gd | survivors_enemy.gd |
| arpg_player.gd | (deleted) |

## 7. Testing Strategy

### 7.1 Unit Tests (gdUnit4)

| Test Suite | Coverage |
|---|---|
| test_survivors_player_stats | health, mana, xp, level, gold, signals |
| test_survivors_enemy_stats | damage, alive check, signals |
| test_weapon_data | defaults, projectile types, rarity |
| test_inventory_data | add, remove, swap, move, signals |
| test_equipment_data | equip, unequip, bonuses, signals |
| test_wave_manager | wave progression, enemy count scaling |

### 7.2 Integration Points

- Player stats → HUD binding updates
- Enemy death → XP gain → level up → card selection flow
- Wave end → summary → shop → next wave flow
- Equipment change → stat bonus recalculation

## 8. Out of Scope

- Multiplayer/networking
- Save/load system
- Procedural map generation
- Boss enemies (future extension)
- Sound effects / music
- Mobile touch input
