extends Resource

class_name EnemyData

@export var isMelee: bool 
@export var enemy_speed: float
@export var enemy_health: float
@export var damage: int
@export var bullet_speed: float
@export var time_between_shots: float
@export var weapon_drop_table: Array[DropTable]
@export var sprite: String
@export var projectile: String
var entities = preload("res://scenes/entities.tscn")
