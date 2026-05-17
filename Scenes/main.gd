extends Node3D

@export var ui_manager : UIManager 
@export var audio_manager : AudioManager 
@export var coin_spawner : CoinSpawner
@export var leaderboard : Leaderboard

@export var Ball : RigidBody3D
@export var playerBody : PlayerBody
@export var FeetController : Node3D

var game_running : bool = false

var current_score = 0


func _ready() -> void:
	audio_manager.play_music()
	if coin_spawner != null:
		coin_spawner.IncreaseCoin.connect(_on_coin_increased)
		#coin_spawner.fixed_z_position = Ball.global_position.z
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
		Ball.hit_coin.connect(_on_coin_increased)
	else:
		push_error("Ball is not assigned in the Main script!")
	ui_manager.retry_pressed.connect(reset_game)
	ui_manager.continue_pressed.connect(_on_continue_pressed)
	ui_manager.menu_pressed.connect(_on_menu_pressed)
	
	ui_manager.changecoin(DataManager.save_data.coins)

func _on_score_increased() -> void:
	audio_manager.play_kick()
	current_score += 1
	ui_manager.changeScore(current_score)
	

func _on_coin_increased() -> void:
	audio_manager.play_coin_collected()
	DataManager.add_coins(1)
	ui_manager.changecoin(DataManager.save_data.coins)

func _on_foot_pressed() -> void:
	if not game_running:
		start_game()

func start_game() -> void:
	game_running = true
	playerBody.startHeadTurn()
	Ball.start_physics()
	coin_spawner.spawn_object() 
	
	
func _on_game_over() -> void:
	if not game_running: return
	audio_manager.stop_music()
	var is_new_record = DataManager.update_high_score(current_score)
	if is_new_record:
		audio_manager.play_highscore()
		leaderboard.sync_leaderboard_data()
	else:
		audio_manager.play_game_over()
		
	game_running = false
	ui_manager.change_menu(UIManager.Menu.GAME_OVER)
	ui_manager.updateGameOver(current_score)
	
	#game_logic_reset()

	

func reset_game() -> void:
	game_logic_reset()
	ui_manager.change_menu(UIManager.Menu.LEVEL)  
	audio_manager.play_music()

func game_logic_reset():
	game_running = false
	Ball.reset_ball()
	playerBody.stop_head_turn()
	coin_spawner.clear_coins()
	current_score = 0
	ui_manager.changeScore(0)

func _on_menu_pressed() -> void:
	game_logic_reset()
	audio_manager.play_music()

func _on_continue_pressed() -> void:
	audio_manager.stop_music()
	_on_rewarded_ad_completed()
	
func _on_rewarded_ad_completed() -> void:
	continue_game()
	
func continue_game() -> void:
	Ball.reset_ball()
	playerBody.stop_head_turn()
	
	ui_manager.change_menu(UIManager.Menu.LEVEL)
	audio_manager.play_music()
	
	
