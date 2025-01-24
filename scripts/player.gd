extends CharacterBody2D
signal hit

const Weapon = preload("res://scripts/weapon.gd")

@export var speed: float = 200.0
@export var acceleration: float = 600.0
@export var friction: float = 500.0
@export var weapons = {}

@onready var cooldown_timer = $CooldownTimer
@onready var crosshair = preload("res://assets/sprites/images/crosshair-alt2.png")


func _ready():
	Input.set_custom_mouse_cursor(crosshair)
	weapons["gun"] = Weapon.create("Gun", 100.0, 2.0, 1.0, 3000, false)
	weapons["ak47"] = Weapon.create("AK47", 150.0, 10.0, 5.0, 800, true)

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	# Get input for movement
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	# Normalize to prevent diagonal speed boost
	direction = direction.normalized()

	if direction != Vector2.ZERO:
		# Apply acceleration in the direction of movement
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		# Apply friction to slow down the character when no input is given
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Get input for shooting
	if Input.is_action_just_released("fireA"):
		weapons["gun"].fire(self)
	if Input.is_action_just_released("fireB"):
		weapons["ak47"].fire(self)
		
	move_and_slide()
	look_at(get_global_mouse_position())
	


func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
