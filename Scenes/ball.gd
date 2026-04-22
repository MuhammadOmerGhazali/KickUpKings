extends RigidBody3D

signal hit_floor
signal hit_foot # NEW: Signal for scoring
var can_score: bool = true

@export var max_speed: float = 10
@export var max_angular_speed: float = 2.0
var z_fixed_position: float = 0.0

func _ready() -> void:
	z_fixed_position = global_position.z
	freeze = true
	contact_monitor = true
	max_contacts_reported = 5 
	body_entered.connect(_on_body_entered)
	angular_damp = 2

func _on_body_entered(body: Node):
	# SCORE LOGIC: Hit a foot
	if body.is_in_group("feet") and can_score:
		can_score = false
		hit_foot.emit()
		await get_tree().create_timer(0.2).timeout # Wait 0.2 seconds
		can_score = true
	
	# GAME OVER LOGIC: Hit the floor
	if body.is_in_group("floor") or body.name == "Floor":
		hit_floor.emit()

func _physics_process(_delta):
	# (Keep your existing speed limits and Z-lock here)
	var current_speed = linear_velocity.length()
	if current_speed > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	global_position.z = z_fixed_position

func start_physics():
	freeze = false
	print("Ball physics activated!")
