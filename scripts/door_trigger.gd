extends Area2D

var tile: Vector2i;
var atlas_coords: Vector2i;
var walls_layer: TileMapLayer;
var just_opened: bool = false;
var time_to_frame: float = 0.1

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		just_opened = true
		for counter in range(6):
			var newX = atlas_coords[1]+1
			if (newX > 6): break
			await get_tree().create_timer(time_to_frame).timeout
			atlas_coords[1] = newX
			walls_layer.set_cell(tile, 1, atlas_coords)
		just_opened = false


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		for counter in range(6):
			if (just_opened): break
			var newX = atlas_coords[1]-1
			if (newX < 3): break 
			await get_tree().create_timer(time_to_frame).timeout
			atlas_coords[1] = newX
			walls_layer.set_cell(tile, 1, atlas_coords)
