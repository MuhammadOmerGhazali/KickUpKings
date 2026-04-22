extends AnimatableBody3D

@export_group("Movement")
@export var drag_speed: float = 15.0
@export var return_speed: float = 10.0

@export_group("Boundaries")
# Drag your two coordinate Node3Ds here in the Inspector
@export var top_limit_node: Node3D
@export var bottom_limit_node: Node3D

@export_group("Rotation")
@export var target_node: Node3D 
@export var rotation_speed: float = 10.0

var dragging: bool = false
var z_fixed_position: float = 0.0
var original_position: Vector3 

signal started_dragging

func _ready():
	original_position = global_position
	z_fixed_position = global_position.z
	input_ray_pickable = true

func _input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		started_dragging.emit()
		if dragging:
			print("Grabbed!")

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragging:
			dragging = false
			print("Dropped - Returning Home")

func _physics_process(delta):
	if dragging:
		var target_pos = get_mouse_3d_on_xy_plane()
		
		# --- NEW: CLAMPING LOGIC ---
		if top_limit_node and bottom_limit_node:
			# Find which node is actually higher/lower to avoid errors
			var min_y = min(top_limit_node.global_position.y, bottom_limit_node.global_position.y)
			var max_y = max(top_limit_node.global_position.y, bottom_limit_node.global_position.y)
			
			# Clamp the target Y before we move
			target_pos.y = clampf(target_pos.y, min_y, max_y)
		
		target_pos.z = z_fixed_position
		global_position = global_position.lerp(target_pos, drag_speed * delta)
	else:
		global_position = global_position.lerp(original_position, return_speed * delta)
		
		if global_position.distance_to(original_position) < 0.01:
			global_position = original_position

	if target_node:
		rotate_stable(delta)

func rotate_stable(delta):
	var dir = target_node.global_position - global_position
	var target_angle = atan2(dir.y, dir.x)
	var final_angle = target_angle + PI 
	rotation.z = lerp_angle(rotation.z, final_angle, rotation_speed * delta)

func get_mouse_3d_on_xy_plane() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	if !camera: return global_position
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var drag_plane = Plane(Vector3(0, 0, 1), z_fixed_position)
	
	var intersection = drag_plane.intersects_ray(ray_origin, ray_direction)
	return intersection if intersection != null else global_position
