extends Area2D

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D:
		body.take_damage(1.0)

func _ready():
	body_entered.connect(_on_body_entered)
