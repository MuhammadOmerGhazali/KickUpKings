extends AnimatableBody3D
class_name PlayerBody

# This allows you to add skins in the Godot Inspector without touching code
@export var skins: Array[CharacterSkin] = []

var current_skin_index: int = 0

func _ready() -> void:
	# Load the skin saved in your DataManager (from our previous chat)
	current_skin_index = DataManager.save_data.current_skin_index
	apply_skin(current_skin_index)
func next_character():
	current_skin_index = (current_skin_index + 1) % skins.size()
	apply_skin(current_skin_index)
func previous_character():
	current_skin_index = (current_skin_index - 1 + skins.size()) % skins.size()
	apply_skin(current_skin_index)
func apply_skin(index: int):
	# 1. Hide all heads and bodies first
	for skin in skins:
		get_node(skin.head_path).visible = false
		get_node(skin.body_path).visible = false
	
	# 2. Show the selected one
	var active_skin = skins[index]
	get_node(active_skin.head_path).visible = true
	get_node(active_skin.body_path).visible = true
	
	# 3. Update the global data so it's remembered next time the game starts
	DataManager.save_data.current_skin_index = index
	DataManager.save_game()

func startHeadTurn():
	$Heads.Start_head_turn()
func stop_head_turn():
	$Heads.Stop_head_turn()
