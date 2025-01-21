extends CharacterBody2D
signal hit

@export var speed: float = 200.0
@export var acceleration: float = 600.0
@export var friction: float = 500.0
@export var bullet_speed = 1000
var bullet = preload("res://assets/sprites/bullet.tscn")

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
	if Input.is_action_just_released("fireA"):
		fire()
	if Input.is_action_just_released("fireB"):
		fire()

	# Normalize to prevent diagonal speed boost
	direction = direction.normalized()

	if direction != Vector2.ZERO:
		# Apply acceleration in the direction of movement
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		# Apply friction to slow down the character when no input is given
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	look_at(get_global_mouse_position())

func fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.linear_velocity = Vector2(bullet_speed, 0).rotated(rotation)
	get_parent().add_child(bullet_instance)
	

func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
