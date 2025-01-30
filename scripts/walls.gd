extends TileMapLayer

var door_trigger = preload("res://scenes/door_trigger.tscn")

func _ready() -> void:
	var all_walls = get_used_cells_by_id(1);
	for tile in all_walls:
		if (check_is_horizontal_door_cell(tile)):
			var door_trigger_instance = door_trigger.instantiate()
			door_trigger_instance.position = map_to_local(tile)
			door_trigger_instance.position.x +=12
			door_trigger_instance.tile = tile
			door_trigger_instance.walls_layer = self
			door_trigger_instance.atlas_coords = get_cell_atlas_coords(tile)
			add_child(door_trigger_instance)
			
		if (check_is_vertical_door_cell(tile)):
			var door_trigger_instance = door_trigger.instantiate()
			door_trigger_instance.position = map_to_local(tile)
			door_trigger_instance.rotation = deg_to_rad(90)
			door_trigger_instance.tile = tile
			door_trigger_instance.walls_layer = self
			door_trigger_instance.atlas_coords = get_cell_atlas_coords(tile)
			add_child(door_trigger_instance)		

func check_is_horizontal_door_cell(tile: Vector2i) -> bool:
	return ( 
		get_cell_atlas_coords(tile) == Vector2i(5,3) ||
		get_cell_atlas_coords(tile) == Vector2i(6,3)
	) 

func check_is_vertical_door_cell(tile: Vector2i) -> bool:
	return (
		get_cell_atlas_coords(tile) == Vector2i(3,3) ||
		get_cell_atlas_coords(tile) == Vector2i(4,3)
	)
