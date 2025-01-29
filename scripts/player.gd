extends CharacterBody2D

@export var health: float = 500
@export var speed: float = 200.0
@export var acceleration: float = 600.0
@export var friction: float = 500.0
@export var weapons = {}
var angle # angulo que o cursor está em relação ao jogador (usado pra mira)

@onready var cooldown_timer = $CooldownTimer
@onready var crosshair = preload("res://assets/sprites/images/crosshair-alt2.png")
@onready var animated_sprite = $AnimatedSprite2D

var flameThrower = preload("res://resources/guns/flamethrower.tres")
var launcher = preload("res://resources/guns/launcher.tres")
var sword = preload("res://resources/guns/sword.tres")
var rigle = preload("res://resources/guns/rifle.tres")
var lasergun = preload("res://resources/guns/lasergun.tres")
var punch = preload("res://resources/guns/punch.tres")

var activeA = "leftArm"
var activeB = "rightArm"

var weapon_scene = preload("res://scenes/weapon.tscn")
	
func equip(weapon_data: Resource):
	var weapon_instance = weapon_scene.instantiate()
	weapon_instance.equipW(weapon_data)
	return weapon_instance

func _ready():
	add_to_group("player")
	Input.set_custom_mouse_cursor(crosshair)
	
	weapons["leftArm"] = equip(punch)	
	weapons["rightArm"] = equip(punch)
	weapons["leftLeg"] = equip(punch)
	weapons["rightLeg"] = equip(punch)
	$leftArm.add_child(weapons["leftArm"])
	$rightArm.add_child(weapons["rightArm"])
	$leftLeg.add_child(weapons["leftLeg"])
	$rightLeg.add_child(weapons["rightLeg"])


func _on_weapon_picked_up(weapon_data: Resource):
	print('equipou', weapon_data)
	#weapons["leftArm"] = equip(weapon_data)
	#$leftArm.add_child(weapons["leftArm"])	

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	# angulo da mira em relação ao player, faz o tiro sair pra direção certa
	angle = direction.angle()
	if velocity.length() > 0: 
		_moveLegsAndArms()
	else:
		_stopMoving()
	
	pickupGuns()

func pickupGuns():
	for weapon in get_tree().get_nodes_in_group("pickups"):
		if weapon and weapon.has_node("WeaponSprite"):  # Garante que tem um Sprite2D
			var sprite = weapon.get_node("WeaponSprite")
			if sprite:
				var texture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
				if texture:
					var texture_size = texture.get_size()
					var weapon_rect = Rect2(weapon.global_position - texture_size * 0.5, texture_size)		
					if weapon_rect.has_point(get_global_mouse_position()):
						var activeAweapon = get_node(activeA)
						var activeBweapon = get_node(activeB)
						if Input.is_action_just_pressed("fireA"):					
							weapons[activeA] = equip(weapon.weapon_data)
							if activeAweapon.get_child_count() > 0:
								activeAweapon.get_child(0).queue_free()
							activeAweapon.add_child(weapons[activeA])
							weapon.queue_free()
						elif Input.is_action_just_pressed("fireB"):
							weapons[activeB] = equip(weapon.weapon_data)
							if activeBweapon.get_child_count() > 0:
								activeBweapon.get_child(0).queue_free()
							activeBweapon.add_child(weapons[activeB])
							weapon.queue_free()


func _stopMoving():
	if _getActiveWeapon() == 'arms':
		$rightLeg.rotation = 0
		$leftLeg.rotation = 0
	else:
		$rightArm.rotation = 0
		$leftArm.rotation = 0
	

func _moveLegsAndArms():
	if _getActiveWeapon() == 'arms':
		$rightLeg.rotation = sin(Time.get_ticks_msec() * 0.015) * -0.4
		$leftLeg.rotation = sin(Time.get_ticks_msec() * 0.015) * 0.4
	else:
		$rightArm.rotation = sin(Time.get_ticks_msec() * 0.0105) * -0.4
		$leftArm.rotation = sin(Time.get_ticks_msec() * 0.015) * 0.4

func _getActiveWeapon():
	if activeA == "leftArm" and activeB == "rightArm":
		return 'arms'
	return 'legs'

# inverte as armas que estao atirando
func _switchWeapon():
	var mouse_pos = get_global_mouse_position()
	var leftArmWeapon = $leftArm.get_child(0)
	var rightArmWeapon = $rightArm.get_child(0)
	var leftLegWeapon = $leftLeg.get_child(0)
	var rightLegWeapon = $rightLeg.get_child(0)
	
	# faz a arma seguir o cursor e congela as outras armas 
	var straightDownAngle = atan2(1, 0)
	if _getActiveWeapon() == 'arms':
		leftArmWeapon.look_at(mouse_pos)
		rightArmWeapon.look_at(mouse_pos)
		leftLegWeapon.rotation = straightDownAngle
		rightLegWeapon.rotation = straightDownAngle
	elif _getActiveWeapon() == 'legs':		
		leftLegWeapon.look_at(mouse_pos)
		rightLegWeapon.look_at(mouse_pos)
		leftArmWeapon.rotation = straightDownAngle
		rightArmWeapon.rotation = straightDownAngle

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
	if Input.is_action_just_pressed("switch"):
		if _getActiveWeapon() == 'arms':
			activeA = "leftLeg"
			activeB = "rightLeg"
		elif _getActiveWeapon() == 'legs':
			activeA = "leftArm"
			activeB = "rightArm"

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
	_switchWeapon()

func take_damage(amount):
	health -= amount
	print(health)
	if health <= 0:		
		print('jogador morreu, falta fazer o game over ou perder vidas')
		animated_sprite.play("death")

# le os eventos de quando o jogador é atingido
func _on_body_entered(body):	
	hide() 
	$CollisionShape2D.set_deferred("disabled", true)
	
func on_weapon_picked_up():
	print('hi')
