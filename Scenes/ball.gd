extends RigidBody3D

signal hit_floor
signal hit_foot 

# Change "$MeshInstance3D" to the actual name/path of your ball's visual mesh
@onready var ball_mesh: MeshInstance3D = $new/Simple

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
	
	setup_unique_material()
	
	# Load the selected ball skin from DataManager
	# current_skin_index = DataManager.save_data.current_ball_index
	apply_skin(current_skin_index)

func setup_unique_material():
	var mat: Material
	
	# Check if a material exists on surface 0
	if ball_mesh.get_active_material(0):
		# Duplicate it so we don't change the original resource
		mat = ball_mesh.get_active_material(0).duplicate()
	else:
		# If no material exists, create a brand new one!
		mat = StandardMaterial3D.new()
		print("No default material found on ball_mesh. Created a new StandardMaterial3D.")
		
	# Apply it as the surface override
	ball_mesh.set_surface_override_material(0, mat)

## Applies the visual texture and saves the choice
func apply_skin(index: int):
	if skins.is_empty() or index >= skins.size():
		push_warning("No skins assigned to the Ball script or invalid index!")
		return

	var active_skin = skins[index]
	var tex = active_skin.ball_texture 
	
	# Get the material we created in setup_unique_material()
	var mat = ball_mesh.get_surface_override_material(0)
	
	# CHANGED: Use BaseMaterial3D. This works for both StandardMaterial3D and ORMMaterial3D!
	if mat is BaseMaterial3D:
		mat.albedo_texture = tex
		mat.albedo_color = Color.WHITE # Forces the base color to white so it doesn't tint your texture
		print("Successfully applied texture: ", tex)
	else:
		push_error("Failed to apply texture! Material is null or not a BaseMaterial3D. Material: ", mat)
		
	current_skin_index = index
## Applies the visual texture and saves the choice
#func apply_skin(index: int):
	#if skins.is_empty() or index >= skins.size():
		#push_warning("No skins assigned to the Ball script or invalid index!")
		#return
#
	#var active_skin = skins[index]
	#var tex = active_skin.ball_texture # Pulls the texture from your resource
	#
	## Get the duplicated material we created in setup_unique_material()
	#var mat = ball_mesh.get_surface_override_material(0)
	#
	## Apply the texture to the material
	#if mat is StandardMaterial3D:
		#mat.albedo_texture = tex
		#
	#current_skin_index = index
	#
	## Persistence: Save the choice globally
	## DataManager.save_data.current_ball_index = index
	## DataManager.save_game()

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
