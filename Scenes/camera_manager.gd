extends Node

@onready var camera: Camera3D = $"../Camera"

# --- CUSTOMIZE YOUR COORDINATES HERE ---

# 1. Level View
const LEVEL_POS = Vector3(0, 4.189, 4.343)
const LEVEL_ROT = Vector3(-5.5, 0, 0)

# 2. Player View
const PLAYER_POS = Vector3(0, 2.251, 4.343)
const PLAYER_ROT = Vector3(-5.5, 0, 0)

# 3. Ball View
const BALL_POS = Vector3(0, 5.043, 0.26)
const BALL_ROT = Vector3(-5.5, 0, 0)

# 4. Place View (Environment/POI)
const PLACE_POS = Vector3(-0, 0.788, 0.254)
const PLACE_ROT = Vector3(-3.3, 0, 0)

# 5. Player Original
const PLAYER_BODY_POS = Vector3(-0, 2.684, -3.513)
const PLAYER_BODY_ROT = Vector3(0, -180.0, 0)

# 5. Player Rotation
const PLAYER_BOD_POS = Vector3(-0.551, 2.684, -3.513)
const PLAYER_BOD_ROT = Vector3(0, -180.0, 0)

var camera_tween: Tween

func _ready() -> void:
	goto_level()

## Moves camera to the Level overview
func goto_level() -> void:
	_tween_camera(LEVEL_POS, LEVEL_ROT)

## Moves camera to focus on the Player
func goto_player() -> void:
	_tween_camera(PLAYER_POS, PLAYER_ROT)

## Moves camera to focus on the Ball
func goto_ball() -> void:
	_tween_camera(BALL_POS, BALL_ROT)

## Moves camera to the specific Place
func goto_place() -> void:
	_tween_camera(PLACE_POS, PLACE_ROT)

# Internal helper to handle the animation logic
func _tween_camera(target_pos: Vector3, target_rot: Vector3, duration: float = 1.2) -> void:
	if camera_tween:
		camera_tween.kill() 
		
	camera_tween = create_tween().set_parallel(true)
	
	# Position Tween
	camera_tween.tween_property(camera, "global_position", target_pos, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Rotation Tween (using degrees)
	camera_tween.tween_property(camera, "global_rotation_degrees", target_rot, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

#func tween_player():
	#$"../Player".position = PLAYER_BOD_POS
	#$"../Player".rotation = PLAYER_BOD_ROT
