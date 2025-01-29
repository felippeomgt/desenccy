extends Area2D

@export var zoom: Vector2 = Vector2(3,3)

@onready var topLeft = $TopLeft
@onready var bottomRight = $BottomRight

func _ready() -> void:
	add_to_group("room")

func _on_body_entered(body: Node2D) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var playerCamera: Camera2D = player.get_node("Camera2D")
		player.get_node("Camera2D").limit_top = topLeft.global_position.y
		player.get_node("Camera2D").limit_left = topLeft.global_position.x
		player.get_node("Camera2D").limit_bottom = bottomRight.global_position.y
		player.get_node("Camera2D").limit_right = bottomRight.global_position.x
		player.get_node("Camera2D").zoom = zoom
