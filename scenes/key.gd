extends Area2D

func _on_key_body_entered(body):
	if body.name == "Player":
		body.has_key = true
		queue_free()
