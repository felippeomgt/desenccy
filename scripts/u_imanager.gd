extends Node

@onready var health_bar = %HealthBar
@onready var lives_label = %Lives
@onready var heat_bar = %WeaponHeat
@onready var weapon_status = %WeaponStatus

func update_health(value: float):
	health_bar.value = value

func update_lives(count: int):
	lives_label.text = "Lives: " + str(count)

func update_heat(value: float, is_overheated: bool):
	heat_bar.value = value
	heat_bar.self_modulate = Color.RED if is_overheated else Color.WHITE

func update_weapon_status(is_arms_active: bool):
	weapon_status.text = "Active: " + ("Arms" if is_arms_active else "Legs")
