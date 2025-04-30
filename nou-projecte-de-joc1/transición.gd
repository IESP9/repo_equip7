extends Control

@onready var label = $Label  # Asegúrate de que el Label esté en un CanvasLayer
@export var target_scene: String = "res://mapa2.tscn"

func _ready():
	label.visible = false  # Ocultamos el texto al inicio
	aparecer_mensaje()

func aparecer_mensaje():
	await get_tree().create_timer(5.0).timeout  # Esperamos 5 segundos
	label.visible = true  # Mostramos el mensaje

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		get_tree().change_scene_to_file(target_scene)  # Cambia de escena
