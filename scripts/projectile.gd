extends RigidBody2D

@export var projectileSprite: AnimatedSprite2D
var damage: float
var projectile: String

func _ready():
	projectileSprite.play(projectile)
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", Callable(self, "_on_body_entered"))
	if projectile == 'punch' or projectile == 'sword':
		await get_tree().create_timer(0.2).timeout
		queue_free()

func _on_body_entered(body):
	print("Collided with: ", body.name)
	print("damage: ", damage)
	if body.is_in_group("enemy"):
		body.take_damage(damage)
	if body.is_in_group("player"):
		body.take_damage(damage)
	queue_free()
