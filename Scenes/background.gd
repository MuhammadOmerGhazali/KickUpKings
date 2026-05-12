extends Node3D

# Change "$BackgroundMesh" to the actual name of your MeshInstance3D in the scene tree
@onready var place_mesh: MeshInstance3D = $Floor/background/Plane_001

@export var place_skins: Array[PlaceSkin] = []
var current_place_index: int = 0

func _ready() -> void:
	setup_unique_material()
	
	# Load the equipped place index from persistent data
	# current_place_index = DataManager.save_data.current_place_index
	apply_place_skin(current_place_index)

func setup_unique_material():
	# Duplicate the material to prevent changing the base resource everywhere
	if place_mesh.get_active_material(0):
		var mat = place_mesh.get_active_material(0).duplicate()
		place_mesh.set_surface_override_material(0, mat)

func apply_place_skin(index: int):
	if place_skins.is_empty() or index >= place_skins.size():
		return
		
	var target_skin = place_skins[index]
	var tex = target_skin.Place_texture
	
	var mat = place_mesh.get_active_material(0)
	
	# Apply the texture to the material
	if mat is StandardMaterial3D:
		mat.albedo_texture = tex
	
	# Update index and save to local storage
	current_place_index = index
	# DataManager.save_data.current_place_index = index
	# DataManager.save_game()

# --- Shop/Selection Navigation Logic ---

## Moves to the next place in the array. Loops to index 0 if at the end.
func next_place():
	if place_skins.is_empty(): return
	
	var next_index = (current_place_index + 1) % place_skins.size()
	apply_place_skin(next_index)

## Moves to the previous place. Loops to the last index if at the start.
func previous_place():
	if place_skins.is_empty(): return
	
	# Adding place_skins.size() ensures the result is never negative
	var prev_index = (current_place_index - 1 + place_skins.size()) % place_skins.size()
	apply_place_skin(prev_index)
