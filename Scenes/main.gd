extends Node3D

@export var ui_manager : UIManager 
@export var audio_manager : AudioManager 
@export var coin_spawner : CoinSpawner

@export var Ball : RigidBody3D
@export var playerBody : PlayerBody
@export var FeetController : Node3D

var game_running : bool = false

var current_score = 0
var current_coins 

func _ready() -> void:
	audio_manager.play_music()
	if coin_spawner != null:
		coin_spawner.IncreaseCoin.connect(_on_coin_increased)
	else:
		push_error("CoinSpawner is not assigned in the Main script!")
	if FeetController != null:
		# Loop through both feet (the children of the controller)
		for foot in FeetController.get_children():
			# Check if the child is actually one of our foot objects with the signal
			if foot.has_signal("foot_pressed"):
				foot.foot_pressed.connect(_on_foot_pressed)
	else:
		push_error("FeetController is not assigned in the Main script!")
		
	if Ball:
		Ball.hit_foot.connect(_on_score_increased)
		Ball.hit_floor.connect(_on_game_over)
	else:
		push_error("Ball is not assigned in the Main script!")
	ui_manager.retry_pressed.connect(reset_game)

func _on_score_increased() -> void:
	audio_manager.play_kick()
	current_score += 1
	ui_manager.changeScore(current_score)
	

func _on_coin_increased() -> void:
	pass

func _on_foot_pressed() -> void:
	if not game_running:
		start_game()

func start_game() -> void:
	game_running = true
	playerBody.startHeadTurn()
	Ball.start_physics()
	
	
func _on_game_over() -> void:
	if not game_running: return
	audio_manager.stop_music()
	var is_new_record = DataManager.update_high_score(current_score)
	if is_new_record:
		audio_manager.play_highscore()
	else:
		audio_manager.play_game_over()
		
	game_running = false
	ui_manager.change_menu(UIManager.Menu.GAME_OVER)
	ui_manager.updateGameOver(current_score)
	
	game_logic_reset()

	

func reset_game() -> void:
	game_logic_reset()
	ui_manager.change_menu(UIManager.Menu.LEVEL)  
	audio_manager.play_music()

func game_logic_reset():
	game_running = false
	Ball.reset_ball()
	playerBody.stop_head_turn()
	current_score = 0
	ui_manager.changeScore(0)
