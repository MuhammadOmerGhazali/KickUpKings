extends Control

signal retry_clicked

func _on_retry_button_pressed() -> void:
	retry_clicked.emit()
