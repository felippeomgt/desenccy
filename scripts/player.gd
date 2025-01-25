extends CharacterBody2D
signal hit

const Weapon = preload("res://scripts/weapon.gd")

@export var speed: float = 200.0
@export var acceleration: float = 600.0
@export var friction: float = 500.0
@export var weapons = {}
var angle # angulo que o cursor está em relação ao jogador (usado pra mira)

@onready var cooldown_timer = $CooldownTimer
@onready var crosshair = preload("res://assets/sprites/images/crosshair-alt2.png")
@onready var animated_sprite = $AnimatedSprite2D

var activeA = "leftArm"
var activeB = "rightArm"

func _ready():
	add_to_group("player")
	Input.set_custom_mouse_cursor(crosshair)
	
	#instancia as armas, só pode esses 4 slots
	#weapon (name, max_cooldown, cooldown_rate, heat_per_shot, overheat_threshold, damage,
	# damage_multiplier, reset_time, high_heat_damage_multiplier, speed, can_hold_shoot)
	weapons["leftArm"] = Weapon.create("Gun", 60.0, 15.0, 10.0, 100.0, 100.0, 1.0, 6.0, 1.65, 2000.0, false)
	weapons["rightArm"] = Weapon.create("AK47", 160.0, 15.0, 10.0, 100.0, 100.0, 1.0, 6, 1.65, 2000, true)
	weapons["leftLeg"] = Weapon.create("AK47", 260.0, 15.0, 10.0, 100.0, 100.0, 1.0, 6, 1.65, 2000, true)
	weapons["rightLeg"] = Weapon.create("AK47", 360.0, 15.0, 10.0, 100.0, 100.0, 1.0, 6, 1.65, 2000, true)

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	# angulo da mira em relação ao player, faz o tiro sair pra direção certa
	angle = direction.angle()

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	# input pros movimentos e animações
	if Input.is_action_pressed("up"):
		direction.y -= 1
		animated_sprite.play("cima_frente")
	if Input.is_action_pressed("down"):		
		direction.y += 1
		animated_sprite.play("baixo_frente")
	if Input.is_action_pressed("left"):
		direction.x -= 1
		animated_sprite.play("esquerda")
	if Input.is_action_pressed("right"):
		direction.x += 1
		animated_sprite.play("direita")
		
	if direction.y > 0 and direction.x > 0:
		animated_sprite.play("baixo_direita")
	elif direction.y < 0 and direction.x < 0:
		animated_sprite.play("cima_esquerda")	
	elif direction.y > 0 and direction.x < 0:
		animated_sprite.play("baixo_esquerda")	
	elif direction.y < 0 and direction.x > 0:
		animated_sprite.play("cima_direita")	
	elif direction.y == 0 and direction.x == 0:
		animated_sprite.play("idle")		
			
	direction = direction.normalized()

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# troca de armas, troca os inputs fireA e o fireB entre braços e pernas
	if Input.is_action_just_released("switch"):
		if activeA == "leftArm":
			activeA = "leftLeg"
		else:
			activeA = "leftArm"
		if activeB == "rightArm":
			activeA = "rightLeg"
		else:
			activeA = "rightArm"

	# verifica se a arma pode metralhar, le o input conforme parametro da arma e atira
	if weapons[activeA].can_hold_shoot:
		if Input.is_action_pressed("fireA"):
			weapons[activeA].fire(self)
	else:
		if Input.is_action_just_released("fireA"):
			weapons[activeA].fire(self)

	if weapons[activeB].can_hold_shoot:
		if Input.is_action_pressed("fireB"):
			weapons[activeB].fire(self)
	else:
		if Input.is_action_just_released("fireB"):
			weapons[activeB].fire(self)
		
	# andar 
	move_and_slide()

# le os eventos de quando o jogador é atingido
func _on_body_entered(body):
	hide() 
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
