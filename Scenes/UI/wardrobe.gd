extends Control

enum state {Player, Ball, Shoes, Place}
var current_state : state = state.Player

@export var player_node: Node3D 
@export var ball_node: RigidBody3D
@export var shoe_node: Node3D 
@export var place_node: Node3D

func _ready():

	update_shop_ui()

func change_state(new_state: state):
	current_state = new_state
	update_shop_ui()

# --- Navigation ---

func _on_next_pressed() -> void:
	$"../../AudioManager".play_click()
	match current_state:
		state.Player: player_node.next_character()
		state.Ball: ball_node.next_skin()
		state.Shoes: shoe_node.next_shoe()
		state.Place: place_node.next_place()
	update_shop_ui()

func _on_previous_pressed() -> void:
	$"../../AudioManager".play_click()
	match current_state:
		state.Player: player_node.previous_character()
		state.Ball: ball_node.previous_skin()
		state.Shoes: shoe_node.previous_shoe()
		state.Place: place_node.previous_place()
	update_shop_ui()

# --- UI Logic ---

func update_shop_ui():
	var is_unlocked: bool = false
	var price: int = 0
	var is_currently_equipped: bool = false
	var high_score = DataManager.save_data.high_score
	
	match current_state:
		state.Player:
			var idx = player_node.current_skin_index
			price = player_node.skins[idx].price
			# Unlocked if in array OR if highscore is high enough
			is_unlocked = DataManager.save_data.unlocked_skins.has(idx) or (high_score >= price)
			is_currently_equipped = (idx == DataManager.save_data.current_skin_index)
			
		state.Ball:
			var idx = ball_node.current_skin_index
			price = ball_node.skins[idx].price
			is_unlocked = DataManager.save_data.unlocked_balls.has(idx) or (high_score >= price)
			is_currently_equipped = (idx == DataManager.save_data.current_ball_index)
			
		state.Shoes:
			var idx = shoe_node.current_shoe_index
			price = shoe_node.shoe_skins[idx].price
			is_unlocked = DataManager.save_data.unlocked_shoes.has(idx) or (high_score >= price)
			is_currently_equipped = (idx == DataManager.save_data.current_shoe_index)
		state.Place:
			var idx = place_node.current_place_index
			price = place_node.place_skins[idx].price
			is_unlocked = DataManager.save_data.unlocked_places.has(idx) or (high_score >= price)
			is_currently_equipped = (idx == DataManager.save_data.current_place_index)

	# Update the Label Text
	if is_currently_equipped:
		$Equip/Label.text = "EQUIPPED"
	elif is_unlocked:
		$Equip/Label.text = "EQUIP"
	else:
		$Equip/Label.text = "REACH " + str(price) + " SCORE"

# This is the "Equip/Unlock" button
func _on_buy_pressed() -> void:
	var data = DataManager.save_data
	$"../../AudioManager".play_click()
	
	match current_state:
		state.Player:
			handle_unlock_and_equip(player_node.current_skin_index, player_node.skins, data.unlocked_skins, "current_skin_index")
		state.Ball:
			handle_unlock_and_equip(ball_node.current_skin_index, ball_node.skins, data.unlocked_balls, "current_ball_index")
		state.Shoes:
			handle_unlock_and_equip(shoe_node.current_shoe_index, shoe_node.shoe_skins, data.unlocked_shoes, "current_shoe_index")
		state.Place:
			handle_unlock_and_equip(place_node.current_place_index, place_node.place_skins, data.unlocked_places, "current_place_index")
	update_shop_ui()

## Handles permanent unlocking via score and equipping
func handle_unlock_and_equip(item_index: int, resource_array: Array, unlocked_list: Array, save_key: String):
	var price = resource_array[item_index].price
	var high_score = DataManager.save_data.high_score

	# 1. Check if the item is "Earned" (Score high enough) or already unlocked
	if high_score >= price or unlocked_list.has(item_index):
		
		# 2. If it's not in the list yet, make it a permanent unlock
		if not unlocked_list.has(item_index):
			unlocked_list.append(item_index)
		
		# 3. Equip the item
		DataManager.save_data.set(save_key, item_index)
		DataManager.save_game()
		print("Permanent unlock/equip successful!")
	else:
		print("Score too low to unlock!")

# --- Transitions & Previews ---

func _on_player_pressed() -> void:
	$"../../AudioManager".play_click()
	change_state(state.Player)
	$"../../CameraManager".goto_player()
	reset_previews_to_equipped()

func _on_ball_pressed() -> void:
	$"../../AudioManager".play_click()
	change_state(state.Ball)
	$"../../CameraManager".goto_ball()
	reset_previews_to_equipped()

func _on_shoes_pressed() -> void:
	$"../../AudioManager".play_click()
	change_state(state.Shoes)
	$"../../CameraManager".goto_place()
	reset_previews_to_equipped()

func _on_location_pressed() -> void:
	$"../../AudioManager".play_click()
	change_state(state.Place)
	$"../../CameraManager".goto_player()
	reset_previews_to_equipped()

func reset_previews_to_equipped():
	player_node.apply_skin(DataManager.save_data.current_skin_index)
	ball_node.apply_skin(DataManager.save_data.current_ball_index)
	shoe_node.apply_shoe_skin(DataManager.save_data.current_shoe_index)
	place_node.apply_place_skin(DataManager.save_data.current_place_index)

func _on_back_pressed() -> void:
	reset_previews_to_equipped()
