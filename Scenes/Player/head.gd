extends Node3D

@export var turn_speed: float = 5.0

# How close the ball can get before the head stops tracking (prevents jitter)
@export var deadzone_distance: float = 0.2

@export_group("Rotation Limits")
@export var min_pitch_deg: float = -45.0 # Lower clamp for X-axis (looking up)
@export var max_pitch_deg: float = 45.0  # Upper clamp for X-axis (looking down)

@export_group("Reset Settings")
@export var reset_duration: float = 1.0  # How long it takes to tween back to 0,0,0

var ball_node: Node3D
var is_tracking: bool = false
var reset_tween: Tween

func _physics_process(delta):
	# Skip the tracking logic entirely if we toggled it off
	if not is_tracking:
		return
		
	# 1. Dynamically find the ball node if we don't have one
	if not is_instance_valid(ball_node):
		var balls_in_scene = get_tree().get_nodes_in_group("ball")
		if balls_in_scene.size() > 0:
			ball_node = balls_in_scene[0]
		else:
			return 
			
	# 2. Get the ball's center position
	var target_pos = ball_node.global_position
	
	# 3. Check distance to prevent "vibration"
	var dist = global_position.distance_to(target_pos)
	if dist < deadzone_distance:
		return 
		
	# 4. Calculate the base target rotation
	var target_transform = global_transform.looking_at(target_pos, Vector3.UP)
	
	# 5. Clamp the X-axis (Pitch)
	var target_euler = target_transform.basis.get_euler()
	target_euler.x = clamp(target_euler.x, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
	target_transform.basis = Basis.from_euler(target_euler)
	
	# 6. Smoothly interpolate the clamped rotation
	global_transform.basis = global_transform.basis.slerp(target_transform.basis, turn_speed * delta)

# Call this function from your input script or UI to toggle tracking
func toggle_tracking():
	is_tracking = !is_tracking
	
	# If a tween is currently running (from a previous toggle), kill it 
	# so it doesn't fight with our physics_process or a new tween
	if reset_tween and reset_tween.is_valid():
		reset_tween.kill()
		
	if not is_tracking:
		# Create a new tween to smoothly rotate back to 0, 0, 0 (Quaternion.IDENTITY)
		reset_tween = create_tween()
		
		# We tween the 'quaternion' property instead of 'rotation' for smoother 3D interpolation
		reset_tween.tween_property(self, "quaternion", Quaternion.IDENTITY, reset_duration)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

func Start_head_turn():
	if is_tracking == false:
		toggle_tracking()

func Stop_head_turn():
	if is_tracking == true:
		toggle_tracking()
