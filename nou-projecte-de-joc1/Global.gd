extends Node

var player: Node3D  # Almacenará la referencia al jugador
var loading_screen = preload("res://LoadingScreen.tscn").instantiate()

func _ready():
	get_tree().root.call_deferred("add_child", loading_screen)

func change_scene_with_loading(target_scene_path: String):
	loading_screen.load_scene(target_scene_path)
