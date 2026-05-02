extends Node
class_name UIManager

# --- Node References ---
#@onready var fade: ColorRect = $"../UI/Fade"
@onready var score_label: Label = $"../UI/Level/Score"
@onready var game_over_label: Label = $"../UI/GameOver/GameOverLabel"
@onready var try_again_button: Button = $"../UI/GameOver/TryAgainButton"


func _ready() -> void:
	# Set initial fade state
	#fade.modulate.a = 0.0
	try_again_button.pressed.connect(func(): print("Button was physically clicked!"))

func Initialize_game_ui() -> void:
	#bottombar_toggle()
	Hide_game_over()
	Show_Score()

# --- Score UI ---
func update_score(new_score: int) -> void:
	score_label.text = str(new_score)
	# Optional juice:
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)

func Show_Score() -> void:
	score_label.show()

func Hide_Score() -> void:
	score_label.hide()

# --- Game Over UI ---
func Show_game_over() -> void:
	game_over_label.show()
	try_again_button.show()
	
	# Fade in background
	#fade.show()
	#var tween = create_tween()
	#tween.tween_property(fade, "modulate:a", 1.0, 0.5)

func Hide_game_over() -> void:
	game_over_label.hide()
	try_again_button.hide()
	
	# Fade out background
	#var tween = create_tween()
	#tween.tween_property(fade, "modulate:a", 0.0, 0.5)
	#tween.tween_callback(fade.hide) # Clean up by hiding it fully once transparent

# --- Bottom Bar ---
