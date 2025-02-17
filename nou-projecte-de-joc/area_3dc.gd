extends Area3D

@export var target_scene: String = "res://pasillo.tscn"


func _on_body_entered(body):
	if body is CharacterBody3D:  # Detecta cualquier personaje
		get_tree().call_deferred("change_scene_to_file", target_scene)
