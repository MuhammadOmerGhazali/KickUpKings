extends Node3D

# --- Node References ---
@onready var ball = $ball
#@onready var left_foot = $LeftFeet
#@onready var right_foot = $RightFeet

# Adjust this path depending on where your UIManager is in the scene tree
@onready var ui_manager = $UiManager

# --- Game Variables ---
var ball_start_pos: Vector3
var score: int = 0
var game_active: bool = false

func _ready() -> void:
	# 1. Store the ball's starting position for resets
	ball_start_pos = ball.global_position
	
	# 2. Connect Signals
	#ball.hit_floor.connect(_on_game_over)
	#ball.hit_foot.connect(_on_ball_scored)
	#left_foot.started_dragging.connect(_on_player_interacted)
	#right_foot.started_dragging.connect(_on_player_interacted)
	
	# If the button is pressed, restart
	ui_manager.try_again_button.pressed.connect(_on_restart_triggered)
	
	# 3. Initial UI Setup via Manager
	score = 0
	ui_manager.Initialize_game_ui()
	ui_manager.update_score(score)

# --- Scoring Logic ---
func _on_ball_scored() -> void:
	score += 1
	ui_manager.update_score(score)

# --- Game State Logic ---
func _on_player_interacted() -> void:
	if not game_active:
		game_active = true
		ball.start_physics() # Tell the ball to start falling


func _on_game_over() -> void:
	ui_manager.Show_game_over()
	ball.freeze = true 
	game_active = false
	print("Game Over! Final Score: ", score)

# --- Restart Logic ---
func _on_restart_triggered() -> void:
	# Ensure we don't trigger this multiple times during gameplay
	if game_active: return
	
	# 1. Reset Score
	score = 0
	ui_manager.update_score(score)
	
	ui_manager.bottombar_toggle()
	# 2. Reset the ball
	ball.freeze = true
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.global_position = ball_start_pos
	
	# 3. Hide Game Over Screen
	ui_manager.Hide_game_over()
