extends Area3D

signal coin_collected1

func _on_body_entered(body: Node3D) -> void:
	print("body entered" + str(body))
	if body.is_in_group("ball"):
		coin_collected1.emit()
		queue_free()
