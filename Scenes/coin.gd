extends Area3D

signal coin_collected 

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball"):
		coin_collected.emit()
		queue_free()
