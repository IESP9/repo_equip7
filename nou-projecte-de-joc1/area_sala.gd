extends Area3D

@export var requiere_nota: bool = true
var jugador_en_sala: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.esta_en_sala_mision = true
		jugador_en_sala = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.esta_en_sala_mision = false
		jugador_en_sala = false
		if requiere_nota and !body.ha_leido_nota:
			# Impide salir si no ha leído la nota
			body.global_transform.origin = get_global_transform().origin
			mostrar_mensaje_bloqueo(body)

func mostrar_mensaje_bloqueo(jugador):
	var ui = jugador.get_node("UI")
	if ui:
		ui.mostrar_mensaje("Debes revisar la sala en busca de pistas antes de salir")
