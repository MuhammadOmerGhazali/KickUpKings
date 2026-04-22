extends Node3D

@export var ball_node: Node3D
@export var turn_speed: float = 5.0

# How close the ball can get before the head stops tracking (prevents jitter)
@export var deadzone_distance: float = 0.2

func _physics_process(delta):
	if ball_node:
		# 1. Get the ball's center position
		var target_pos = ball_node.global_position
		
		# 2. Check distance to prevent "vibration" when ball is too close
		var dist = global_position.distance_to(target_pos)
		if dist < deadzone_distance:
			return # Stop tracking if it's too close to avoid jitter
			
		# 3. Calculate the target rotation
		# looking_at() creates a transform pointing at the ball
		var target_transform = global_transform.looking_at(target_pos, Vector3.UP)
		
		# 4. Smoothly interpolate the rotation (Slerp)
		# We do this in _physics_process to match the ball's movement speed
		global_transform.basis = global_transform.basis.slerp(target_transform.basis, turn_speed * delta)
		
		# --- GLTF FIX ---
		# rotate_object_local(Vector3.UP, PI)
