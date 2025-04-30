extends Node3D

# Referencias a nodos
@onready var wave_label: Label = $Control/Label
@export var spawn_controller: Node3D
@export var boss_scene: PackedScene = preload("res://bosst.tscn")
@export var next_scene: PackedScene = preload("res://mapa3.tscn")  # Cargar la escena de antemano

# Configuración
var wave_started = false
var current_wave: int = 0
var max_waves: int = 10
var all_waves_completed = false

func _ready():
	# Configurar jugador
	var player_node = get_node_or_null("CharacterBody3D")
	if player_node:
		Global.player = player_node
	else:
		push_error("Error: No se encontró al jugador en la escena.")
	
	# Verificar que el SpawnController esté conectado
	if spawn_controller:
		spawn_controller.oleada_terminada.connect(_on_oleada_terminada)
		spawn_controller.boss_derrotado.connect(_on_boss_derrotado)
	else:
		push_error("Error: SpawnController no está asignado.")
	
	update_wave_label()
	wave_label.visible = true

func update_wave_label():
	if current_wave == 0:
		wave_label.text = "¡Preparate! Presiona [E] para comenzar la oleada 1"
	elif current_wave >= max_waves:
		wave_label.text = "¡TODAS LAS OLEADAS COMPLETADAS!\nPreparando siguiente área..."
		all_waves_completed = true
		start_transition()
	else:
		wave_label.text = "Oleada %d completada. Presiona [E] para comenzar la oleada %d" % [current_wave, current_wave + 1]

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if not wave_started and current_wave < max_waves:
			start_next_wave()
		elif all_waves_completed:
			# Permitir saltar la espera si ya completó todas las oleadas
			force_transition()

func start_next_wave():
	current_wave += 1
	wave_started = true
	wave_label.visible = true
	
	if current_wave == 5 or current_wave == 10:
		wave_label.text = "¡OLEADA %d - APARECE EL BOSS!" % current_wave
	else:
		wave_label.text = "¡Oleada %d ha comenzado!" % current_wave
	
	# Esperar 3 segundos antes de ocultar el mensaje
	await get_tree().create_timer(3.0).timeout
	wave_label.visible = false
	
	# Iniciar la oleada
	spawn_controller.start_wave(current_wave)

func _on_oleada_terminada():
	wave_started = false
	
	# Spawnear boss si es ronda 5 o 10
	if current_wave == 5 or current_wave == 10:
		spawn_boss()
	else:
		update_wave_label()
		wave_label.visible = true
		
		# Si es la última oleada, iniciar transición
		if current_wave >= max_waves:
			start_transition()

func _on_boss_derrotado():
	update_wave_label()
	wave_label.visible = true
	
	# Si era la oleada 10, iniciar transición
	if current_wave >= max_waves:
		start_transition()

func spawn_boss():
	var boss = boss_scene.instantiate()
	add_child(boss)
	boss.global_transform.origin = Vector3(0, 0, 10)  # Ajustar posición
	
	if boss.has_signal("boss_derrotado"):
		boss.connect("boss_derrotado", Callable(spawn_controller, "_on_boss_derrotado"))
	
	print("¡BOSS HA APARECIDO EN LA OLEADA ", current_wave, "!")

func start_transition():
	wave_label.visible = true
	wave_label.text = "¡TODAS LAS OLEADAS COMPLETADAS!\nTransicionando en 3 segundos..."
	
	# Esperar 3 segundos antes de cambiar
	await get_tree().create_timer(3.0).timeout
	transition_to_next_map()

func force_transition():
	# Para saltar la espera manualmente
	print("Transición forzada por el jugador")
	transition_to_next_map()

func transition_to_next_map():
	print("Iniciando transición a mapa3.tscn")
	
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		push_error("Error: No se pudo cargar la siguiente escena")
		# Opción alternativa
		var error = get_tree().change_scene_to_file("res://mapa3.tscn")
		if error != OK:
			push_error("Fallo al cargar mapa3.tscn, código de error: ", error)
