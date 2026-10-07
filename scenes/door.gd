extends Area2D
func _ready():
	body_entered.connect(_on_body_entered)
func _on_body_entered(body):
	if body.name == "Player" and body.has_key:
		get_tree().change_scene_to_file("res://assets/game/jieshu/game_over2.tscn")
