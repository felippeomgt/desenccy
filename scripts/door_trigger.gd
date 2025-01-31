extends Area2D

@onready var door_adio: AudioStreamPlayer2D = $AudioStreamPlayer2D

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
		play_open_sound()
		for counter in range(6):
			var newX = atlas_coords[1]+1
			if (newX > 6): break
			await get_tree().create_timer(time_to_frame).timeout
			atlas_coords[1] = newX
			walls_layer.set_cell(tile, 1, atlas_coords)
		just_opened = false


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		play_close_sound()
		for counter in range(6):
			if (just_opened): break
			var newX = atlas_coords[1]-1
			if (newX < 3): break 
			await get_tree().create_timer(time_to_frame).timeout
			atlas_coords[1] = newX
			walls_layer.set_cell(tile, 1, atlas_coords)
			
func play_open_sound():
	door_adio.play(0.35);
	await get_tree().create_timer(0.65).timeout
	if (door_adio.playing): door_adio.stop();
	
func play_close_sound():
	door_adio.play(2.30);
	await get_tree().create_timer(1).timeout
	if (door_adio.playing): door_adio.stop();
