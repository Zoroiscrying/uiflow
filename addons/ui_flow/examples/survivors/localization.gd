## SurvivorsLocalization — simple EN/CN language switching.
extends Node

signal language_changed

var _lang: String = "en"
var _strings: Dictionary = {}


func _init() -> void:
	_init_strings()


func _init_strings() -> void:
	_strings = {
		# HUD
		"controls_hint": {
			"en": "WASD: Move | Auto-shoot | I: Backpack | P: Equipment | Esc: Pause | F1: Source",
			"cn": "WASD: 移动 | 自动射击 | I: 背包 | P: 装备 | Esc: 暂停 | F1: 源码",
		},
		"dps_label": {
			"en": "DPS",
			"cn": "秒伤",
		},
		# Level Up
		"level_up_title": {
			"en": "Level Up!",
			"cn": "升级！",
		},
		# Shop
		"shop_title": {
			"en": "Shop",
			"cn": "商店",
		},
		"buy": {
			"en": "Buy",
			"cn": "购买",
		},
		"close": {
			"en": "Close",
			"cn": "关闭",
		},
		"not_enough_gold": {
			"en": "Not enough gold!",
			"cn": "金币不足！",
		},
		"bought_item": {
			"en": "Bought %s!",
			"cn": "购买了 %s！",
		},
		# Wave Summary
		"wave_complete": {
			"en": "Wave %d Complete!",
			"cn": "第 %d 波完成！",
		},
		"enter_shop": {
			"en": "Shop",
			"cn": "商店",
		},
		"skip": {
			"en": "Skip",
			"cn": "跳过",
		},
		"enemy": {
			"en": "Enemy",
			"cn": "敌人",
		},
		"killed": {
			"en": "Killed",
			"cn": "击杀",
		},
		"xp": {
			"en": "XP",
			"cn": "经验",
		},
		"gold": {
			"en": "Gold",
			"cn": "金币",
		},
		# Backpack
		"backpack_title": {
			"en": "Backpack",
			"cn": "背包",
		},
		"empty_slot": {
			"en": "Empty Slot",
			"cn": "空槽位",
		},
		"equip": {
			"en": "Equip",
			"cn": "装备",
		},
		"drop": {
			"en": "Drop",
			"cn": "丢弃",
		},
		"examine": {
			"en": "Examine",
			"cn": "查看",
		},
		"equipped_item": {
			"en": "Equipped %s!",
			"cn": "装备了 %s！",
		},
		"dropped_item": {
			"en": "Dropped %s.",
			"cn": "丢弃了 %s。",
		},
		# Equipment
		"equipment_title": {
			"en": "Equipment",
			"cn": "装备",
		},
		# Pause
		"paused": {
			"en": "Paused",
			"cn": "暂停",
		},
		"resume": {
			"en": "Resume",
			"cn": "继续",
		},
		"main_menu": {
			"en": "Main Menu",
			"cn": "主菜单",
		},
		"quit_confirm_title": {
			"en": "Quit?",
			"cn": "退出？",
		},
		"quit_confirm_msg": {
			"en": "Return to main menu?",
			"cn": "返回主菜单？",
		},
		# Game Over
		"game_over": {
			"en": "Game Over",
			"cn": "游戏结束",
		},
		"restart": {
			"en": "Restart",
			"cn": "重新开始",
		},
		# Wave notifications
		"wave_incoming": {
			"en": "Wave %d incoming!",
			"cn": "第 %d 波来袭！",
		},
		"wave_cleared": {
			"en": "Wave cleared! Next wave incoming...",
			"cn": "波次清除！下一波即将到来...",
		},
		# Shop guard
		"cant_shop_during_wave": {
			"en": "Can't shop during a wave!",
			"cn": "战斗中无法打开商店！",
		},
		# Code panel
		"source_code": {
			"en": "Source Code",
			"cn": "源代码",
		},
		"ui_flow_api": {
			"en": "UIFlow API",
			"cn": "UIFlow API",
		},
		# Stats
		"stat": {
			"en": "Stat",
			"cn": "属性",
		},
		"value": {
			"en": "Value",
			"cn": "数值",
		},
		"waves_survived": {
			"en": "Waves Survived",
			"cn": "存活波数",
		},
		"total_kills": {
			"en": "Total Kills",
			"cn": "总击杀",
		},
		# Language
		"language": {
			"en": "EN",
			"cn": "中",
		},
	}


## Get a localized string.
func loc(key: String) -> String:
	if _strings.has(key):
		var entry: Dictionary = _strings[key]
		return entry.get(_lang, entry.get("en", key))
	return key


## Get a localized formatted string.
func locf(key: String, args: Array) -> String:
	return loc(key) % args


## Current language code.
func get_lang() -> String:
	return _lang


## Toggle between EN and CN.
func toggle_language() -> void:
	if _lang == "en":
		_lang = "cn"
	else:
		_lang = "en"
	language_changed.emit()


## Set language explicitly.
func set_lang(lang: String) -> void:
	if lang != _lang:
		_lang = lang
		language_changed.emit()
