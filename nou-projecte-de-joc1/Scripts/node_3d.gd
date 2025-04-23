extends Node3D

@export var target_scene: String = "res://mapa2.tscn"
@onready var message_label = $CanvasLayer/WaveLabel  # Ajusta la ruta al Label
@onready var player = $"../Player"  # Ajusta la ruta al jugador si es necesario

var fake_zombies = 5  # Simulación de zombies

func _process(delta):
	if fake_zombies == 0:
		wave_completed()

	# Prueba: Reduce los zombies con "Z"
	if Input.is_action_just_pressed("ui_accept"):  # ENTER por defecto
		fake_zombies -= 1
		print("Zombies restantes:", fake_zombies)

func wave_completed():
	message_label.text = "¡Oleada Completada!"
	message_label.visible = true  # Muestra el mensaje
	await get_tree().create_timer(2.0).timeout  # Espera 2 segundos
	get_tree().change_scene_to_file(target_scene)  # Cambia de nivel
