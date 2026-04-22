extends Node3D

# --- Node References ---
@onready var ball = $ball
@onready var left_foot = $LeftFeet
@onready var right_foot = $RightFeet
@onready var fade = $UI/Fade
@onready var score_label = $UI/Score
@onready var game_over_label = $UI/GameOver
@onready var try_again_button = $UI/TryAgainButton

# --- Game Variables ---
var ball_start_pos: Vector3
var score: int = 0
var game_active: bool = false

func _ready() -> void:
	# 1. Store the ball's starting position for resets
	ball_start_pos = ball.global_position
	
	# 2. Connect Ball Signals
	# Ensure these signals exist in your Ball script!
	ball.hit_floor.connect(_on_game_over)
	ball.hit_foot.connect(_on_ball_scored)
	left_foot.started_dragging.connect(_on_player_interacted)
	right_foot.started_dragging.connect(_on_player_interacted)
	
	# 3. Initial UI Setup
	score = 0
	update_score_display()
	
	fade.modulate.a = 0.0 # Start transparent
	game_over_label.hide()
	try_again_button.hide()
	score_label.show()

# --- Scoring Logic ---

func _on_ball_scored() -> void:
	score += 1
	update_score_display()
	# Optional: Add a little "juice" like a temporary scale up when scoring
	# var tween = create_tween()
	# tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	# tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)

func update_score_display() -> void:
	score_label.text = str(score)

# --- Game State Logic ---

func _on_game_over() -> void:
	# 1. Fade in the background
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	
	# 2. Show Game Over UI
	game_over_label.show()
	try_again_button.show()
	
	# 3. Freeze the ball so it stops calculating physics
	ball.freeze = true 
	print("Game Over! Final Score: ", score)

func _on_try_again_button_pressed() -> void:
	# 1. Reset Score
	score = 0
	update_score_display()
	game_active = false
	# 2. Reset the ball
	# We unfreeze first, then reset position and clear all movement
	ball.freeze = true
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.global_position = ball_start_pos
	
	# 3. Fade out the background
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)
	
	# 4. Reset UI visibility
	game_over_label.hide()
	try_again_button.hide()
	score_label.show()


func _on_player_interacted():
	if not game_active:
		game_active = true
		ball.start_physics() # Tell the ball to start falling
