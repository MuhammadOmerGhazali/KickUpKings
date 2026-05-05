extends Node3D
class_name CoinSpawner

@export_category("Spawn Settings")
@export var object_to_spawn: PackedScene
@export var fixed_z_position: float = 0.0

@export_category("Spawn Area Limits")
@export var min_x: float = -10.0
@export var max_x: float = 10.0
@export var min_y: float = 0.0
@export var max_y: float = 5.0

signal IncreaseCoin

func _ready() -> void:
	randomize()

func spawn_object() -> void:
	if object_to_spawn == null:
		push_error("No scene assigned to the Spawner!")
		return
	var random_x := randf_range(min_x, max_x)
	var random_y := randf_range(min_y, max_y)
	var spawn_position := Vector3(random_x, random_y, fixed_z_position)
	var new_object = object_to_spawn.instantiate()
	new_object.coin_collected.connect(coin_collected)
	add_child(new_object)
	new_object.global_position = spawn_position
	
func coin_collected():
	IncreaseCoin.emit()
	spawn_object()
