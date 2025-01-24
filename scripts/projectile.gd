extends RigidBody2D

#class_name Projectile
var bullet_speed: float = 1000.0

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Collided with: ", body.name) 
	queue_free()

#static func create(_bullet_speed:float) -> Projectile:
#	var projectile_instance = Projectile.new()
#	projectile_instance.bullet_speed = _bullet_speed
#	return projectile_instance
