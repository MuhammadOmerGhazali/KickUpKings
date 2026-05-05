extends AnimatableBody3D

signal foot_pressed

@export var top_clamp: Node3D
@export var bottom_clamp: Node3D
@export var pivot: Node3D

@export_category("Movement Settings")
@export var follow_speed: float = 15.0
@export var return_speed: float = 10.0
@export var rotation_speed: float = 15.0 # Increased slightly for snappier overall rotation

@export_category("Drag Tilt Settings")
@export var tilt_multiplier: float = 2.0 # How deeply it tilts (the angle)
@export var tilt_speed: float = 25.0 # NEW: How FAST it snaps into the tilt (was 12.0)
@export var max_tilt_degrees: float = 45.0 

var _dragging := false
var _origin := Vector3.ZERO
var _origin_basis: Basis
var _z := 0.0

# Tracks the smoothed direction of our dragging
var _drag_velocity := Vector3.ZERO 

func _ready():
	_origin = global_position
	_origin_basis = global_basis
	_z = global_position.z
	input_ray_pickable = true

# This fires when the mouse/touch hits THIS body's collision shape directly
func _input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			foot_pressed.emit()
			print("foot pressed")
	elif event is InputEventScreenTouch:
		if event.pressed:
			_dragging = true
			foot_pressed.emit()

func _input(event):
	# Release anywhere on screen
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			_dragging = false
	if event is InputEventScreenTouch and not event.pressed:
		_dragging = false

func _physics_process(delta):
	# 1. Read the transform ONCE
	var new_transform := global_transform
	var current_scale := new_transform.basis.get_scale() 
	
	if _dragging:
		# --- Position Logic ---
		var target_pos := _mouse_on_plane()
		target_pos = _clamped(target_pos)
		
		# Calculate how fast and in what direction we are moving right now
		var move_vector := target_pos - new_transform.origin
		
		# Smooth the movement vector using our new tilt_speed!
		_drag_velocity = _drag_velocity.lerp(move_vector, tilt_speed * delta)
		
		# Move the actual transform
		new_transform.origin = new_transform.origin.lerp(target_pos, follow_speed * delta)
		
		# --- Combined Rotation Logic ---
		if pivot != null and new_transform.origin.distance_to(pivot.global_position) > 0.01:
			var dir := (pivot.global_position - new_transform.origin).normalized()
			var up_vector := Vector3.UP
			if abs(dir.dot(Vector3.UP)) > 0.99:
				up_vector = Vector3.FORWARD
				
			# Base target: Looking at the pivot
			var look_transform := new_transform.looking_at(pivot.global_position, up_vector)
			var base_quat := Quaternion(look_transform.basis.orthonormalized())
			
			# --- The New Tilt Logic ---
			var pitch_angle := _drag_velocity.y * tilt_multiplier
			var yaw_angle := _drag_velocity.x * tilt_multiplier
			
			var max_rads := deg_to_rad(max_tilt_degrees)
			pitch_angle = clamp(pitch_angle, -max_rads, max_rads)
			yaw_angle = clamp(yaw_angle, -max_rads, max_rads)
			
			var tilt_quat := Quaternion.from_euler(Vector3(pitch_angle, yaw_angle, 0))
			
			var final_target_quat := base_quat * tilt_quat
			var current_quat := Quaternion(new_transform.basis.orthonormalized())
			
			new_transform.basis = Basis(current_quat.slerp(final_target_quat, rotation_speed * delta))
			
	else:
		# --- Return Logic ---
		# Fade out the drag velocity so it gracefully settles
		_drag_velocity = _drag_velocity.lerp(Vector3.ZERO, return_speed * delta)
		
		new_transform.origin = new_transform.origin.lerp(_origin, return_speed * delta)
		if new_transform.origin.distance_to(_origin) < 0.01:
			new_transform.origin = _origin
			
		var current_quat := Quaternion(new_transform.basis.orthonormalized())
		var origin_quat := Quaternion(_origin_basis.orthonormalized())
		new_transform.basis = Basis(current_quat.slerp(origin_quat, return_speed * delta))

	# 2. Re-apply the scale
	new_transform.basis.x *= current_scale.x
	new_transform.basis.y *= current_scale.y
	new_transform.basis.z *= current_scale.z
	
	# 3. Apply everything back
	global_transform = new_transform

func _mouse_on_plane() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return global_position
	var mouse := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse)
	var ray_dir    := cam.project_ray_normal(mouse)
	
	var t := (_z - ray_origin.z) / ray_dir.z
	if t < 0:
		return global_position
	
	return Vector3(
		ray_origin.x + ray_dir.x * t,
		ray_origin.y + ray_dir.y * t,
		_z
	)

func _clamped(pos: Vector3) -> Vector3:
	if top_clamp == null or bottom_clamp == null:
		return pos
	var lo := bottom_clamp.global_position
	var hi := top_clamp.global_position
	return Vector3(
		clamp(pos.x, min(lo.x, hi.x), max(lo.x, hi.x)),
		clamp(pos.y, min(lo.y, hi.y), max(lo.y, hi.y)),
		_z
	)
