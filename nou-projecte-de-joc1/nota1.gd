extends Node3D

# Señal que se emitirá cuando el jugador lea la nota
signal nota_fue_leida

@export var nota_texto: String = "Si lees esto… nos acabamos de ir.

No tuvimos elección. Esperamos todo lo que pudimos, pero la situación se volvió insostenible. El pasillo ya no es seguro. Escuchamos cómo arañaban las puertas, golpeaban las paredes… estaban demasiado cerca.

Carlos insistió en que aún podíamos aguantar aquí, que quizás alguien vendría a rescatarnos. Pero nadie vendrá. Nadie nos ha contactado en horas. Marta encontró un viejo mapa y convenció a los demás de que el mejor plan era salir antes de que nos quedáramos atrapados.

No sabemos si el refugio del norte es real, pero es nuestra única opción. Nos vamos con lo que pudimos cargar: algo de agua, unas pocas provisiones y una linterna que parpadea más de lo que ilumina.

Si estás leyendo esto, significa que te quedaste atrás… o que acabas de llegar. Si es lo primero, corre. No sabemos cuánto más podrán aguantar esas barricadas. Si es lo segundo… tal vez aún puedas alcanzarnos.

Nos dirigimos al puente principal. No sabemos qué nos espera al otro lado, pero quedarse aquí es un suicidio.

Corre.

— Los últimos de la oficina."

@onready var area = $Sprite3D/Area3D

var jugador_en_rango = false
var nota_leida = false
var nota_actualmente_visible = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	add_to_group("NotasImportantes")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		jugador_en_rango = true
		mostrar_mensaje_interaccion()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		jugador_en_rango = false
		ocultar_mensaje_interaccion()
		if nota_actualmente_visible:
			ocultar_nota()

func _input(event):
	if jugador_en_rango and event.is_action_pressed("interact"):
		if nota_actualmente_visible:
			ocultar_nota()
		else:
			mostrar_nota()
		get_viewport().set_input_as_handled()

func mostrar_nota():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")
		if ui:
			ui.mostrar_nota(nota_texto)
			if !nota_leida:
				jugador.ha_leido_nota = true
				nota_leida = true
				emit_signal("nota_fue_leida")
				# Verificar que estamos en office.tscn antes de completar misión
				if get_tree().current_scene.scene_file_path == "res://office.tscn":
					ui.completar_mision()
			nota_actualmente_visible = true
			habilitar_controles_jugador(jugador, false)

func ocultar_nota():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")
		if ui:
			ui.ocultar_nota()
			nota_actualmente_visible = false
			habilitar_controles_jugador(jugador, true)

func habilitar_controles_jugador(jugador, habilitar: bool):
	# Control de cámara
	var camara = jugador.get_node("player_Camera")
	if camara and camara.has_method("set_process_input"):
		camara.set_process_input(habilitar)
	
	# Control de movimiento
	if jugador.has_method("set_process_input"):
		jugador.set_process_input(habilitar)

func mostrar_mensaje_interaccion():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")
		if ui:
			var mensaje = "Presiona E para %s" % ["leer" if !nota_actualmente_visible else "cerrar"]
			ui.mostrar_mensaje_interaccion(mensaje)

func ocultar_mensaje_interaccion():
	var jugador = get_tree().get_first_node_in_group("Player")
	if jugador:
		var ui = jugador.get_node("UI")
		if ui:
			ui.ocultar_mensaje_interaccion()
