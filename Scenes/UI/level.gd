extends Control

@export var score_label : Label


func _ready() -> void:
	score_label.text = str(0)


func increase_score(new_score : int):
	score_label.text = str(new_score)
