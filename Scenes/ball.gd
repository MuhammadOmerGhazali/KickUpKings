extends RigidBody3D

signal hit_floor
signal hit_foot 

# --- Skin System Variables ---
@export var skins: Array[BallSkin] = []
var current_skin_index: int = 0

# --- Physics Variables ---
@export var max_speed: float = 10
@export var max_angular_speed: float = 2.0
var z_fixed_position: float = 0.0
var can_score: bool = true

var initial_position: Vector3

func _ready() -> void:
	z_fixed_position = global_position.z
	initial_position = global_position
	freeze = true
	contact_monitor = true
	max_contacts_reported = 5 
	body_entered.connect(_on_body_entered)
	angular_damp = 2
	
	# Load the selected ball skin from DataManager
	current_skin_index = DataManager.save_data.current_ball_index
	apply_skin(current_skin_index)

## Applies the visual mesh and saves the choice
func apply_skin(index: int):
	if skins.is_empty():
		push_warning("No skins assigned to the Ball script!")
		return

	# 1. Hide all ball visuals first
	for skin in skins:
		var node = get_node_or_null(skin.ball_path)
		if node:
			node.visible = false
	
	# 2. Show the selected one
	var active_skin = skins[index]
	var active_node = get_node_or_null(active_skin.ball_path)
	if active_node:
		active_node.visible = true
		current_skin_index = index
		
		# 3. Persistence: Save the choice globally
		DataManager.save_data.current_ball_index = index
		DataManager.save_game()
	else:
		push_error("Ball skin node not found at path: ", active_skin.ball_path)

# --- Navigation Functions for Shop UI ---

func next_skin():
	if skins.is_empty(): return
	var next_index = (current_skin_index + 1) % skins.size()
	apply_skin(next_index)

func previous_skin():
	if skins.is_empty(): return
	var prev_index = (current_skin_index - 1 + skins.size()) % skins.size()
	apply_skin(prev_index)

# --- Gameplay Logic ---

func _on_body_entered(body: Node):
	if body.is_in_group("feet") and can_score:
		can_score = false
		hit_foot.emit()
		await get_tree().create_timer(0.2).timeout
		can_score = true
	
	if body.is_in_group("floor") or body.name == "Floor":
		hit_floor.emit()

func _physics_process(_delta):
	global_position.z = z_fixed_position
	
	var current_velocity = linear_velocity
	if current_velocity.length() > max_speed:
		linear_velocity = current_velocity.normalized() * max_speed

func start_physics():
	freeze = false
	print("Ball physics activated!")


func reset_ball():
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_position = initial_position
	var physics_body_state = PhysicsServer3D.body_get_direct_state(get_rid())
	if physics_body_state:
		physics_body_state.transform = global_transform
	
	can_score = true
	print("Ball physics forced to reset.")
