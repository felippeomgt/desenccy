extends CanvasLayer

@onready var health_bar = $MarginContainer/HealthBar
@onready var lives_label = $MarginContainer/Lives
@onready var heat_bar = $MarginContainer/WeaponHeat
@onready var weapon_status = $MarginContainer/WeaponStatus

func update_health(value: float):
	health_bar.value = value
	health_bar.self_modulate = Color(1, value, value)  # Fica mais vermelho conforme perde vida

func update_lives(count: int):
	lives_label.text = "[b]Lives:[/b] " + str(count)

func update_heat(value: float, is_overheated: bool):
	heat_bar.value = value
	heat_bar.self_modulate = Color(1, 0.5, 0) if is_overheated else Color(0, 1, 1)  # Vermelho no overheat

func update_weapon_status(is_arms_active: bool):
	weapon_status.text = "[b]Active:[/b] " + ("[color=cyan]Arms[/color]" if is_arms_active else "[color=orange]Legs[/color]")
