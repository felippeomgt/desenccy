extends RigidBody2D

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	pass
	#gravity_scale = 0

func _on_body_entered(body):
	## aqui adicionar codigo para cada tipo de colisão
	queue_free()
