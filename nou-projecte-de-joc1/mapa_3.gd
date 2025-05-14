extends Node3D

# Referencias a nodos
@onready var wave_label: Label = $Control/Label
@export var spawn_controller: Node3D
@export var boss_scene: PackedScene = preload("res://bosst.tscn")

# Configuración
var wave_started = false
var current_wave: int = 0
var max_waves: int = 10
var transition_timer: Timer
var puede_iniciar_oleadas: bool = false

func _ready():
	# Configurar jugador
	var player_node = get_node_or_null("CharacterBody3D")
	if player_node:
		Global.player = player_node
	else:
		push_error("Error: No se encontró al jugador en la escena.")
	
	# Crear timer para transición
	transition_timer = Timer.new()
	transition_timer.one_shot = true
	transition_timer.timeout.connect(_on_transition_timeout)
	add_child(transition_timer)
	
	# Mostrar mensaje inicial y configurar espera
	wave_label.text = "¡EL BOSS HA APARECIDO, DERROTALO!"
	wave_label.visible = true
	
	# Temporizador para esperar 30 segundos
	var espera_inicial = get_tree().create_timer(30.0)
	await espera_inicial.timeout
	
	puede_iniciar_oleadas = true
	update_wave_label()

	if not spawn_controller:
		push_error("Error: SpawnController no está asignado.")

func update_wave_label():
	if not puede_iniciar_oleadas:
		return
		
	if current_wave == 0:
		wave_label.text = "¡Preparate! Presiona [E] para comenzar la oleada 1"
	elif current_wave >= max_waves:
		wave_label.text = "¡Ronda completada! Cargando siguiente nivel..."
	else:
		wave_label.text = "Oleada %d completada. Presiona [E] para comenzar la oleada %d" % [current_wave, current_wave + 1]

func _input(event):
	if not puede_iniciar_oleadas:
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_E and not wave_started and current_wave < max_waves:
		start_next_wave()

func start_next_wave():
	if not puede_iniciar_oleadas:
		return
		
	current_wave += 1
	wave_started = true
	wave_label.visible = true
	
	if current_wave == 5 or current_wave == 10:
		wave_label.text = "¡OLEADA %d - APARECE EL BOSS!" % current_wave
	else:
		wave_label.text = "¡Oleada %d ha comenzado!" % current_wave
	
	if spawn_controller:
		spawn_controller.start_wave(current_wave)
		
		# Esperar 3 segundos antes de ocultar el mensaje
		await get_tree().create_timer(3.0).timeout
		wave_label.visible = false
		
		# Esperar a que termine la oleada
		await spawn_controller.oleada_terminada
		wave_started = false
		
		# Spawnear boss si es ronda 5 o 10
		if current_wave == 5 or current_wave == 10:
			spawn_boss()
			await spawn_controller.boss_derrotado
		
		update_wave_label()
		wave_label.visible = true
		
		# Si completamos todas las oleadas, iniciar transición
		if current_wave >= max_waves:
			transition_timer.start(3.0)  # Esperar 3 segundos antes de cambiar de nivel
	else:
		push_error("Error: SpawnController no está asignado")

func spawn_boss():
	var boss = boss_scene.instantiate()
	add_child(boss)
	boss.global_transform.origin = Vector3(0, 0, 10)  # Ajustar posición
	
	if boss.has_signal("boss_derrotado"):
		boss.connect("boss_derrotado", Callable(spawn_controller, "_on_boss_derrotado"))
	
	print("¡BOSS HA APARECIDO EN LA OLEADA ", current_wave, "!")

func _on_transition_timeout():
	# Cambiar al mapa3.tscn
	print("Transición a mapa3.tscn")
	get_tree().change_scene_to_file("res://mapa4.tscn")
