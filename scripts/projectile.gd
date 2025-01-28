extends RigidBody2D

@export var projectileSprite: AnimatedSprite2D
var damage: float

func _ready():
	projectileSprite.play()
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Collided with: ", body.name)
	print("damage: ", damage)
	if body.is_in_group("enemy"):
		body.take_damage(damage)
	if body.is_in_group("player"):
		body.take_damage(damage)
	queue_free()
