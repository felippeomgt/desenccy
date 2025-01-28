extends Node2D


@export var damage: float
@export var speed: float
@export var can_hold_shoot: bool = false
@export var weapon_name: String = "fist"
@export var max_cooldown: float = 100.0 
@export var cooldown_rate: float = 2.0  # Quanto resfria por segundo
@export var heat_per_shot: float = 20.0  # Quanto esquenta por tiro
@export var damage_multiplier: float = 1.0  # Dano base
@export var high_heat_damage_multiplier: float = 1.5  # 70%+ de cooldown, mais dano
@export var reset_time: float = 3.0  # Tempo para resetar após superaquecer
@export var fire_rate: float = 0.2 
@export var projectile: String = 'punch'
@onready var animated_sprite = $WeaponSprite

var current_cooldown: float = 0.0
var is_overheated: bool = false
var cooldown_timer: Timer = Timer.new()
var last_shot_time = 0.0

# carregar os projectiles baseado no nome da arma (weapon_name) dps, pra nao precisar manualmente colocar cada um, a gente define pelo nome da arma
@export var projectile_instance = preload("res://scenes/projectile.tscn")

func equipW(weapon_data: Resource):
	weapon_name = weapon_data.weapon_name
	max_cooldown = weapon_data.max_cooldown
	cooldown_rate = weapon_data.cooldown_rate
	heat_per_shot = weapon_data.heat_per_shot
	damage = weapon_data.damage
	damage_multiplier = weapon_data.damage_multiplier
	high_heat_damage_multiplier = weapon_data.high_heat_damage_multiplier
	reset_time = weapon_data.reset_time
	can_hold_shoot = weapon_data.can_hold_shoot
	fire_rate = weapon_data.fire_rate
	projectile = weapon_data.projectile	
	speed = weapon_data.speed
	print(speed)


func _init() -> void:
	add_child(cooldown_timer)

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play(weapon_name)

func fire(origin_node):	
	var current_time = Time.get_ticks_msec() / 1000.0  # Tempo atual em segundos
	if current_time - last_shot_time >= fire_rate:
		last_shot_time = current_time
		pass
	else:
		return
		
	if is_overheated:
		print("Weapon is overheated!")
		return

	current_cooldown += heat_per_shot
	if current_cooldown >= max_cooldown:
		_trigger_overheat()
		is_overheated = true
		return
	
	# Se o cooldown está acima de 70%, aumenta o dano
	if current_cooldown >= max_cooldown * 0.7:
		damage_multiplier = high_heat_damage_multiplier
	else:
		damage_multiplier = 1.0 # default 1.0

	print("Atirando.. Cooldown: ", current_cooldown, " Dano: ", damage_multiplier)
	
	var projectileInstanced = projectile_instance.instantiate()
	projectileInstanced.projectile = projectile
	projectileInstanced.damage = damage
	
	# O certo era sair a bala do $BulletHole, mas por alguma razao obscura as vezes ele fica null, dai o fallback é o braço do player
	if $BulletHole == null:
		projectileInstanced.position = origin_node.global_position
	else:
		projectileInstanced.position = $BulletHole.global_position
		
	projectileInstanced.rotation_degrees = rad_to_deg(origin_node.angle)
	#if projectile != 'punch' and projectile != 'sword':

	print(speed)
	projectileInstanced.linear_velocity = Vector2(speed, 0).rotated(origin_node.angle)
	origin_node.get_parent().add_child(projectileInstanced) 

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
