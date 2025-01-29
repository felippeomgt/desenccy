extends Node2D

@export var enemy_count: int
@export var enemies_list: Array[EnemyData]
@export var spawn_area: Rect2
@export var waves: int
@export var wave_timeout: float

var enemy_instance = preload("res://scenes/entities.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_enemies()

func spawn_enemies():
	for k in range(waves):
		for i in range(enemy_count):			
			var enemy_resource = enemies_list[randi() % enemies_list.size()]
			var enemy_instance = enemy_resource.entities.instantiate()
			enemy_instance.spawn(enemy_resource)
			
			var random_position = Vector2(
				randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
				randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
			)
			var spawn_position = spawn_area.position + random_position
			print("Random spawn position: ", spawn_position)
			enemy_instance.global_position = spawn_position
		
			get_parent().add_child(enemy_instance)
			await get_tree().create_timer(wave_timeout).timeout
			
