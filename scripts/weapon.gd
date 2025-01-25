extends Node2D

class_name Weapon


@export var overheated: bool = false
@export var damage: float = 100
@export var speed: float = 1000
@export var can_hold_shoot: bool = false
@export var weapon_name: String = "gun"
@export var max_cooldown: float = 100.0 
@export var cooldown_rate: float = 2.0  # Quanto resfria por segundo
@export var heat_per_shot: float = 20.0  # Quanto esquenta por tiro
@export var overheat_threshold: float = 100.0  # Quando chega a 100, não pode atirar
@export var damage_multiplier: float = 1.0  # Dano base
@export var high_heat_damage_multiplier: float = 1.5  # 70%+ de cooldown, mais dano
@export var reset_time: float = 3.0  # Tempo para resetar após superaquecer

var current_cooldown: float = 0.0
var is_overheated: bool = false

var cooldown_timer: Timer = Timer.new()

# carregar os projectiles baseado no nome da arma (weapon_name) dps, pra nao precisar manualmente colocar cada um, a gente define pelo nome da arma
@export var projectile_instance = preload("res://scenes/projectile.tscn")

# construct da classe
static func create(_name: String, _max_cooldown: float, _cooldown_rate: float, _heat_per_shot:float, _overheat_threshold:float, _damage: float, _damage_multiplier: float, _reset_time:float, _high_heat_damage_multiplier:float, _speed:float, _can_hold_shoot: bool) -> Weapon:
	var weapon_instance = Weapon.new()
	weapon_instance.weapon_name = _name
	weapon_instance.max_cooldown = _max_cooldown
	weapon_instance.cooldown_rate = _cooldown_rate
	weapon_instance.heat_per_shot = _heat_per_shot
	weapon_instance.overheat_threshold = _overheat_threshold
	weapon_instance.damage = _damage
	weapon_instance.damage_multiplier = _damage_multiplier
	weapon_instance.high_heat_damage_multiplier = _high_heat_damage_multiplier
	weapon_instance.reset_time = _reset_time
	weapon_instance.can_hold_shoot = _can_hold_shoot
	return weapon_instance

func _init() -> void:
	add_child(cooldown_timer)

func _ready() -> void:
	print(cooldown_timer)


func fire(origin_node):
	if is_overheated:
		print("Weapon is overheated!")
		return

	current_cooldown += heat_per_shot
	if current_cooldown >= overheat_threshold:
		_trigger_overheat()
		is_overheated = true
		return
	
	# Se o cooldown está acima de 70%, aumenta o dano
	if current_cooldown >= max_cooldown * 0.7:
		damage_multiplier = high_heat_damage_multiplier
	else:
		damage_multiplier = 1.0 # default 1.0

	print("Atirando.. Cooldown: ", current_cooldown, " Dano: ", damage_multiplier)
		
	var projectile = projectile_instance.instantiate()
	projectile.position = origin_node.global_position
	projectile.rotation_degrees = rad_to_deg(origin_node.angle)
	projectile.linear_velocity = Vector2(speed, 0).rotated(origin_node.angle)
	origin_node.get_parent().add_child(projectile) 

# funciona nos inimigos, nao funciona pro player, talvez porque a arma é instanciada dinamicamente, nao sei
func _trigger_overheat():	
	print(cooldown_timer)
	cooldown_timer.stop()
	print("Weapon overheated! Cooling down...")
	cooldown_timer.start() 
	await cooldown_timer.timeout
	current_cooldown = 0
	is_overheated = false
	print("Weapon cooled down and ready to fire again!")

func _on_CooldownTimer_timeout():
	if current_cooldown > 0:
		current_cooldown = max(0, current_cooldown - cooldown_rate)
