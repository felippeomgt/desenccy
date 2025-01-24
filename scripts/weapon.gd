extends Node2D

class_name Weapon

@export var gun_name: String
@export var cooldown: float = 0.0
@export var max_cooldown: float
@export var cooldown_rate: float
@export var overheated: bool = false
@export var damage: float = 100
@export var speed: float = 1000
@export var can_hold_shoot: bool = false

@export var projectile_instance = preload("res://scenes/projectile.tscn")
@export var cooldown_timer: Timer

# construct da classe
static func create(_name: String, _max_cooldown: float, _cooldown_rate: float, _damage: float, _speed:float, _can_hold_shoot: bool) -> Weapon:
	var weapon_instance = Weapon.new()
	weapon_instance.gun_name = _name
	weapon_instance.max_cooldown = _max_cooldown
	weapon_instance.cooldown_rate = _cooldown_rate
	weapon_instance.damage = _damage
	weapon_instance.can_hold_shoot = _can_hold_shoot	
	weapon_instance._initialize_timer()	
	return weapon_instance
	
func _ready():
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = 1
	cooldown_timer.autostart = true
	cooldown_timer.timeout.connect(reduce_cooldown())
	add_child(cooldown_timer)
	

# timer do cooldown de tiros
func _initialize_timer():	
	print('cooldown timer started')
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = 1.0  # Tempo de intervalo de redução do cooldown
	cooldown_timer.autostart = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)

func fire(player_node):
	if overheated:
		print(name + " is overheated!")
		return
		
	if cooldown < max_cooldown:
		cooldown += cooldown_rate
		if cooldown >= max_cooldown:
			overheated = true			
			print(name + " overheated! Cooldown needed.")
			return
	else:
		print(name + " on cooldown!")
		
	var projectile = projectile_instance.instantiate()
	projectile.position = player_node.global_position
	projectile.rotation_degrees = player_node.rotation_degrees
	projectile.linear_velocity = Vector2(speed, 0).rotated(player_node.rotation)
	player_node.get_parent().add_child(projectile) 


func reduce_cooldown():
	print('so queria q funcionasse')
	if cooldown > 0:
		cooldown -= cooldown_rate
		if cooldown < max_cooldown * 0.7:
			damage = damage * 1.5
		else: 
			damage = damage * 1
	if overheated and cooldown <= 0 :
		overheated = false
		cooldown = 0
		cooldown_timer.stop()


func _on_cooldown_timeout():
	print('coldown timeout triggered')
	if cooldown > 0:
		cooldown -= cooldown_rate
		if cooldown < max_cooldown * 0.7:
			damage = 1.5  # Aumento de dano ao atingir 70%
		else:
			damage = 1.0

	if overheated and cooldown <= 0:
		overheated = false
		print(name + " is ready to fire again.")


func _on_weapon_cooldown_timeout() -> void:
	print('nao funciona pq é uma merda')
	reduce_cooldown()
