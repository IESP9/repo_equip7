extends Area3D

@export var target_scene: String = "res://esp.tscn"  # La escena a la que se teletransportará
var saltos_realizados = 0
var jugador_dentro = false

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body is CharacterBody3D:
		jugador_dentro = true
		body.jumped.connect(_on_jugador_salto)  # Conectar la señal de salto

func _on_body_exited(body):
	if body is CharacterBody3D:
		jugador_dentro = false
		saltos_realizados = 0  # Reiniciamos los saltos si sale del área
		body.disconnect("jumped", _on_jugador_salto)  # Evitamos que se quede conectado

func _on_jugador_salto():
	if jugador_dentro:
		saltos_realizados += 1
		if saltos_realizados >= 5:
			get_tree().change_scene_to_file(target_scene)  # Cambia de escena
