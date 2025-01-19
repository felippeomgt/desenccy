extends CharacterBody2D


signal hit

const FRICTION: float = 0.15
@export var acceleration: int = 40
@export var max_speed: int = 100
@export var speed: int = 400
var mov_direction: Vector2 = Vector2.ZERO



func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_just_pressed("right"):
		velocity.x +=1
	if Input.is_action_just_pressed("left"):
		velocity.x -= 1
	if Input.is_action_just_pressed("up"):
		velocity.y += 1
	if Input.is_action_just_pressed("down"):
		velocity.y -= 1
		
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		# play moving animation
	else:
		velocity = Vector2.ZERO
		# play stopped animation


func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
