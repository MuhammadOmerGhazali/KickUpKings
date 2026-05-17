extends Control

class_name GameOverUi

signal retry_button_clicked
signal continue_button_pressed
signal menu_button_pressed

@export var continue_button : TextureButton

@export var float_distance: float = 15.0 
@export var float_duration: float = 1.0  

# Keep a reference to the tween so we can pause/play it
var float_tween: Tween

func _ready() -> void:
	# Connect to this node's own visibility changes
	visibility_changed.connect(_on_visibility_changed)
	
	# Setup the animation once
	_setup_continue_button_animation()

func _setup_continue_button_animation() -> void:
	if not continue_button:
		return
		
	var start_pos = continue_button.position
	var up_pos = start_pos + Vector2(0, -float_distance)
	
	# Create the tween and store it in our variable
	float_tween = create_tween().set_loops()
	float_tween.set_trans(Tween.TRANS_SINE)
	float_tween.set_ease(Tween.EASE_IN_OUT)
	
	float_tween.tween_property(continue_button, "position", up_pos, float_duration)
	float_tween.tween_property(continue_button, "position", start_pos, float_duration)
	
	# Pause it immediately if the menu starts out hidden
	if not visible:
		float_tween.pause()

# This function runs automatically whenever visible is set to true or false
func _on_visibility_changed() -> void:
	if float_tween:
		if visible:
			float_tween.play()  # Resume animating when the menu opens
		else:
			float_tween.pause() # Stop wasting CPU when the menu closes

# --- Signals Below ---
func _on_retry_button_pressed() -> void:
	retry_button_clicked.emit()

func _on_menu_button_pressed() -> void:
	menu_button_pressed.emit()

func _on_continue_button_pressed() -> void:
	continue_button_pressed.emit()
