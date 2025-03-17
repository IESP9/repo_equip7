extends Node3D

@export var nota_texto: String = "Si lees esto… nos acabamos de ir.

No tuvimos elección. Esperamos todo lo que pudimos, pero la situación se volvió insostenible. El pasillo ya no es seguro. Escuchamos cómo arañaban las puertas, golpeaban las paredes… estaban demasiado cerca.

Carlos insistió en que aún podíamos aguantar aquí, que quizás alguien vendría a rescatarnos. Pero nadie vendrá. Nadie nos ha contactado en horas. Marta encontró un viejo mapa y convenció a los demás de que el mejor plan era salir antes de que nos quedáramos atrapados.

No sabemos si el refugio del norte es real, pero es nuestra única opción. Nos vamos con lo que pudimos cargar: algo de agua, unas pocas provisiones y una linterna que parpadea más de lo que ilumina.

Si estás leyendo esto, significa que te quedaste atrás… o que acabas de llegar. Si es lo primero, corre. No sabemos cuánto más podrán aguantar esas barricadas. Si es lo segundo… tal vez aún puedas alcanzarnos.

Nos dirigimos al puente principal. No sabemos qué nos espera al otro lado, pero quedarse aquí es un suicidio.

Corre.

— Los últimos de la oficina."  # Texto que mostrará la nota
@onready var area = $Sprite3D/Area3D

var jugador_en_rango = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		jugador_en_rango = true
		mostrar_mensaje_interaccion()  # Mostrar mensaje "Tocar [E] para leer el mensaje"

func _on_body_exited(body):
	if body.is_in_group("Player"):
		jugador_en_rango = false
		ocultar_mensaje_interaccion()  # Ocultar mensaje
		ocultar_nota()

func _input(event):
	if jugador_en_rango and event.is_action_pressed("interact"):
		mostrar_nota()

func mostrar_nota():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")  # Obtener la UI del jugador
		if ui:
			ui.mostrar_nota(nota_texto)

func ocultar_nota():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")  # Obtener la UI del jugador
		if ui:
			ui.ocultar_nota()

func mostrar_mensaje_interaccion():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")  # Obtener la UI del jugador
		if ui:
			ui.mostrar_mensaje_interaccion()

func ocultar_mensaje_interaccion():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")  # Obtener la UI del jugador
		if ui:
			ui.ocultar_mensaje_interaccion()
