extends Node2D

@export var enemy_count: int
@export var enemies_list: Array[EnemyData]
@export var waves: int
@export var wave_timeout: float

@onready var spawn_area = $SpawnArea
@onready var collision_shape = $SpawnArea/CollisionShape2D

var has_spawned = false
var enemy_instance = preload("res://scenes/entities.tscn")

func _ready() -> void:	
	if spawn_area:
		spawn_area.body_entered.connect(_on_spawn_area_body_entered)

func spawn_enemies():
	if not collision_shape or not collision_shape.shape is RectangleShape2D:
		print("No valid CollisionShape2D found for spawn area!")
		return
	
	var rect_size = collision_shape.shape.size
	var rect_position = spawn_area.global_position - (rect_size / 2)

	for k in range(waves):
		for i in range(enemy_count):			
			var enemy_resource = enemies_list[randi() % enemies_list.size()]
			var enemy_instance = enemy_resource.entities.instantiate()
			enemy_instance.spawn(enemy_resource)
			
			var random_position = Vector2(
				randf_range(rect_position.x, rect_position.x + rect_size.x),
				randf_range(rect_position.y, rect_position.y + rect_size.y)
			)

			enemy_instance.global_position = random_position
			print("Random spawn position: ", random_position)
			get_parent().add_child(enemy_instance)
			
		if wave_timeout > 0:
			await get_tree().create_timer(wave_timeout).timeout

func _on_spawn_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not has_spawned:
		has_spawned = true
		spawn_enemies()
