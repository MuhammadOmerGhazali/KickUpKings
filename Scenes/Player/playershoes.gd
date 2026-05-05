extends Node3D

@onready var right_foot: MeshInstance3D = $RightFeet/White
@onready var left_foot: MeshInstance3D = $LeftFeet/White

@export var shoe_skins: Array[ShoeSkin] = []
var current_shoe_index: int = 0

func _ready() -> void:
	setup_unique_materials()
	
	# Load the equipped shoe index from persistent data
	current_shoe_index = DataManager.save_data.current_shoe_index
	apply_shoe_skin(current_shoe_index)

func setup_unique_materials():
	# Duplicate materials to prevent changing every instance in the game
	var mat_r = right_foot.get_active_material(0).duplicate()
	var mat_l = left_foot.get_active_material(0).duplicate()
	
	right_foot.set_surface_override_material(0, mat_r)
	left_foot.set_surface_override_material(0, mat_l)

func apply_shoe_skin(index: int):
	if shoe_skins.is_empty() or index >= shoe_skins.size():
		return
		
	var target_skin = shoe_skins[index]
	var tex = target_skin.shoe_texture
	
	var mat_r = right_foot.get_surface_override_material(0)
	var mat_l = left_foot.get_surface_override_material(0)
	
	if mat_r is StandardMaterial3D and mat_l is StandardMaterial3D:
		mat_r.albedo_texture = tex
		mat_l.albedo_texture = tex
	
	# Update index and save to local storage
	current_shoe_index = index
	DataManager.save_data.current_shoe_index = index
	DataManager.save_game()

# --- Shop Navigation Logic ---

## Moves to the next shoe in the array. Loops to index 0 if at the end.
func next_shoe():
	if shoe_skins.is_empty(): return
	
	var next_index = (current_shoe_index + 1) % shoe_skins.size()
	apply_shoe_skin(next_index)

## Moves to the previous shoe. Loops to the last index if at the start.
func previous_shoe():
	if shoe_skins.is_empty(): return
	
	# Adding shoe_skins.size() ensures the result is never negative
	var prev_index = (current_shoe_index - 1 + shoe_skins.size()) % shoe_skins.size()
	apply_shoe_skin(prev_index)
