extends Control

enum state {Player, Ball, Shoes}
var current_state : state = state.Player

# Link these in the Inspector so the UI can talk to the 3D objects
@export var player_node: Node3D 
@export var ball_node: RigidBody3D
@export var shoe_node: Node3D # The node containing your shoe script

func _ready():
	update_shop_ui()

func change_state(new_state: state):
	current_state = new_state
	update_shop_ui()

func _on_next_pressed() -> void:
	match current_state:
		state.Player: player_node.next_character()
		state.Ball: ball_node.next_skin()
		state.Shoes: shoe_node.next_shoe()
	update_shop_ui()
func _on_previous_pressed() -> void:
	match current_state:
		state.Player: player_node.previous_character()
		state.Ball: ball_node.previous_skin()
		state.Shoes: shoe_node.previous_shoe()
	update_shop_ui()

## Updates the Buy Button text based on ownership
func update_shop_ui():
	var is_owned: bool = false
	var price: int = 0
	var is_currently_equipped: bool = false
	
	# 1. Check ownership and price based on current state
	match current_state:
		state.Player:
			var idx = player_node.current_skin_index
			is_owned = DataManager.save_data.unlocked_skins.has(idx)
			price = player_node.skins[idx].price
			is_currently_equipped = (idx == DataManager.save_data.current_skin_index)
			
		state.Ball:
			var idx = ball_node.current_skin_index
			is_owned = DataManager.save_data.unlocked_balls.has(idx)
			price = ball_node.skins[idx].price
			is_currently_equipped = (idx == DataManager.save_data.current_ball_index)
			
		state.Shoes:
			var idx = shoe_node.current_shoe_index
			is_owned = DataManager.save_data.unlocked_shoes.has(idx)
			price = shoe_node.shoe_skins[idx].price
			is_currently_equipped = (idx == DataManager.save_data.current_shoe_index)

	# 2. Update the Label Text
	if is_currently_equipped:
		$Equip/Label.text = "EQUIPPED"
	elif is_owned:
		$Equip/Label.text = "EQUIP"
	else:
		$Equip/Label.text = "LOCKED"

func _on_buy_pressed() -> void:
	var data = DataManager.save_data
	
	match current_state:
		state.Player:
			handle_transaction(player_node.current_skin_index, player_node.skins, data.unlocked_skins, "current_skin_index")
		state.Ball:
			handle_transaction(ball_node.current_skin_index, ball_node.skins, data.unlocked_balls, "current_ball_index")
		state.Shoes:
			handle_transaction(shoe_node.current_shoe_index, shoe_node.shoe_skins, data.unlocked_shoes, "current_shoe_index")
	
	update_shop_ui()

## Handles the logic of buying vs equipping
func handle_transaction(item_index: int, resource_array: Array, unlocked_list: Array, save_key: String):
	# If already owned, just equip it
	if unlocked_list.has(item_index):
		DataManager.save_data.set(save_key, item_index)
		DataManager.save_game()
		return

	# If not owned, try to buy
	var price = resource_array[item_index].price
	if DataManager.save_data.coins >= price:
		DataManager.save_data.coins -= price
		unlocked_list.append(item_index)
		DataManager.save_data.set(save_key, item_index)
		DataManager.save_game()
		print("Purchase successful!")
	else:
		print("Not enough coins!")




func _on_player_pressed() -> void:
	change_state(state.Player)
	$"../../CameraManager".goto_player()



func _on_ball_pressed() -> void:
	change_state(state.Ball)
	$"../../CameraManager".goto_ball()


func _on_shoes_pressed() -> void:
	change_state(state.Shoes)
	$"../../CameraManager".goto_place()
