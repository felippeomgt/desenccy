extends CharacterBody2D
 
@export var isMelee: bool = false
@export var enemy_speed: float = 100.0
@export var enemy_health: float = 100.0
@export var weapon_scene: PackedScene
@export var damage: int = 100
@export var bullet_speed: float = 1000
@export var time_between_shots: float = 2.0
@export var weapon_drop_table: Array = [
	{"weapon": preload("res://resources/guns/flamethrower.tres"), "chance": 0.3},
	{"weapon": preload("res://resources/guns/lasergun.tres"), "chance": 0.3},
	{"weapon": preload("res://resources/guns/launcher.tres"), "chance": 0.3},
	{"weapon": preload("res://resources/guns/punch.tres"), "chance": 0.3},
	{"weapon": preload("res://resources/guns/rifle.tres"), "chance": 0.3},
	{"weapon": preload("res://resources/guns/sword.tres"), "chance": 0.3},
]

var weaponsScene = preload("res://scenes/weapon.tscn")

@onready var health_bar = $HealthBar
@onready var weapon_holder = $Weapon
@onready var spawn_zone = $SpawnZone
@onready var shoot_timer = $Timer

var hunt = true
var original_health: float
var player = null
var is_active = false
var angle

func _ready() -> void:	
	original_health = enemy_health
	health_bar.play('100')
	add_to_group("enemy")
	find_player()
	shoot_timer.connect("timeout", _on_shoot_timer_timeout)
	shoot_timer.wait_time = time_between_shots
	shoot_timer.start()

func find_player():
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player = player_node
		is_active = true

func _process(delta: float) -> void:
	if not player:
		find_player()
		return
	if is_active and player:
		if hunt:
			_move_towards_player()
		else:
			_move_away_player()
		angle = global_position.angle_to_point(player.global_position)
		_play_animation_based_on_angle(rad_to_deg(angle))

func _move_towards_player():
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * enemy_speed
	move_and_slide()

func _move_away_player():
	var direction = (player.global_position + global_position).normalized()
	velocity = direction * enemy_speed
	move_and_slide()

func spawn_enemy_outside_screen():
	var camera = get_viewport().get_camera_2d()
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_distance = max(screen_size.x, screen_size.y) * 1.2
	
	var angle = randf_range(0, 2 * PI)
	global_position = camera.global_position + Vector2(spawn_distance, 0).rotated(angle)

func fire_at_player():
	if weapon_holder.get_child_count() == 0 and weapon_scene:
		var weapon_instance = weapon_scene.instantiate()
		weapon_holder.speed = bullet_speed
		weapon_holder.damage = damage
		weapon_holder.add_child(weapon_instance)
		
	var direction = (player.global_position - global_position).normalized()
	weapon_holder.look_at(player.global_position)	
	weapon_holder.fire(self)

func take_damage(amount):
	enemy_health -= amount
	var health_percentage = float(enemy_health) / original_health
	var animation_index = floor(health_percentage * 10)
	animation_index = clamp(animation_index, 0, 9)
	
	health_bar.play(str(animation_index*10))
	if enemy_health <= 0:
		is_active = false
		die()


func die() -> void:
	$AnimatedSprite2D.play("death")	
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	queue_free()
	drop_weapon()

func _on_shoot_timer_timeout() -> void:
	if is_active and player:
		fire_at_player()

func _play_animation_based_on_angle(angle_degrees):
	angle_degrees = fmod(angle_degrees + 360.0, 360.0) # Normalize angle to 0-360
	if angle_degrees >= 337.5 or angle_degrees < 22.5:
		$AnimatedSprite2D.play("right")
	elif angle_degrees >= 22.5 and angle_degrees < 67.5:
		$AnimatedSprite2D.play("down_right")
	elif angle_degrees >= 67.5 and angle_degrees < 112.5:
		$AnimatedSprite2D.play("down_idle")
	elif angle_degrees >= 112.5 and angle_degrees < 157.5:
		$AnimatedSprite2D.play("down_left")
	elif angle_degrees >= 157.5 and angle_degrees < 202.5:
		$AnimatedSprite2D.play("left")
	elif angle_degrees >= 202.5 and angle_degrees < 247.5:
		$AnimatedSprite2D.play("up_left")
	elif angle_degrees >= 247.5 and angle_degrees < 292.5:
		$AnimatedSprite2D.play("up")
	elif angle_degrees >= 292.5 and angle_degrees < 337.5:
		$AnimatedSprite2D.play("up_right")

func drop_weapon() -> void:
	var rng = randi() % 100 / 100.0  # Número aleatório entre 0 e 1
	var cumulative_chance = 0
	for item in weapon_drop_table:
		cumulative_chance += item["chance"]
		if rng <= cumulative_chance:
			var dropped_weapon = item["weapon"].duplicate()
			spawn_weapon(dropped_weapon)
			break

func spawn_weapon(weapon: Resource) -> void:
	var weapon_instance = weaponsScene.instantiate()
	weapon_instance.weapon_data = weapon
	weapon_instance.equipW(weapon)
	weapon_instance.add_to_group("pickups")
	get_parent().add_child(weapon_instance)
	weapon_instance.position = position

func _on_spawn_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		await get_tree().create_timer(0.2).timeout
		hunt = false

func _on_spawn_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		await get_tree().create_timer(0.2).timeout
		hunt = true
