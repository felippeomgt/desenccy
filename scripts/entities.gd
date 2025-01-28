extends CharacterBody2D
 

@export var enemy_speed: float = 100.0
@export var enemy_health: float = 100.0
@export var weapon_scene: PackedScene
@export var damage: int = 100
@export var bullet_speed: float = 1000
@export var time_between_shots: float = 2.0
@export var weapon_drop_table: Array = [
	{"weapon": preload("res://resources/guns/rifle.tres"), "chance": 0.3},
]

@onready var health_bar = $HealthBar

@onready var weapon_holder = $Weapon
@onready var spawn_zone = $SpawnZone
@onready var shoot_timer = $Timer

var original_health: float
var player = null
var is_active = false
var angle

func equip(weapon_data: Resource):
	var weapon_instance = weapon_scene.instantiate()
	weapon_instance.weapon_name = weapon_data.weapon_name
	weapon_instance.max_cooldown = weapon_data.max_cooldown
	weapon_instance.cooldown_rate = weapon_data.cooldown_rate
	weapon_instance.heat_per_shot = weapon_data.heat_per_shot
	weapon_instance.damage = weapon_data.damage
	weapon_instance.damage_multiplier = weapon_data.damage_multiplier
	weapon_instance.high_heat_damage_multiplier = weapon_data.high_heat_damage_multiplier
	weapon_instance.reset_time = weapon_data.reset_time
	weapon_instance.can_hold_shoot = weapon_data.can_hold_shoot
	weapon_instance.fire_rate = weapon_data.fire_rate
	weapon_instance.projectile = weapon_data.projectile	
	return weapon_instance

func _ready() -> void:	
	original_health = enemy_health
	health_bar.play('100')
	add_to_group("enemy")
	find_player()
	#animated_sprite.sprite_frames = sprite_frames
	spawn_zone.connect("body_entered", _on_spawn_zone_area_entered)
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
		_move_towards_player()
		angle = global_position.angle_to_point(player.global_position)
		_play_animation_based_on_angle(rad_to_deg(angle))

func _move_towards_player():
	var direction = (player.global_position - global_position).normalized()
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
	await get_tree().create_timer(1.0).timeout
	
	queue_free()

func _on_spawn_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		is_active = true

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
