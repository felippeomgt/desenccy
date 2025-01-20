extends CharacterBody2D
signal hit

@export var speed: float = 200.0
@export var acceleration: float = 600.0
@export var friction: float = 500.0

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

	move_and_slide()

func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
