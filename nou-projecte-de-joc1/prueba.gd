extends Node3D

# Señales
signal oleada_terminada
signal boss_derrotado

# Referencias
@onready var spawn_area: Node3D = $SpawnArea
@onready var zombie_scene: PackedScene = preload("res://enemy.tscn")
@onready var zombie2_scene: PackedScene = preload("res://enemy2.tscn")  # Nuevo enemigo

# Configuración
@export var zombies_base_por_oleada: int = 5
@export var incremento_por_oleada: int = 5
@export var tiempo_entre_spawns: float = 2.0
@export var tiempo_espera_final: float = 10.0
@export var probabilidad_enemy2: float = 0.2  # 20% de chance de spawnear enemy2
@export var incremento_probabilidad_por_oleada: float = 0.02  # Aumenta 5% por oleada

# Estado
var wave_active = false
var zombies_en_escena: int = 0
var boss_active: bool = false
var current_wave: int = 0  # Para llevar registro de la oleada actual

func _ready():
	if not spawn_area:
		push_error("Error: spawn_area no está asignado.")

func start_wave(wave_number: int):
	if wave_active:
		return
	
	current_wave = wave_number
	wave_active = true
	print("¡Iniciando oleada %d!" % wave_number)
	
	# Calcular zombies para esta oleada
	var zombies_esta_oleada = zombies_base_por_oleada + (wave_number - 1) * incremento_por_oleada
	
	# Ajustar para rondas de boss (menos zombies normales)
	if wave_number == 5 or wave_number == 10:
		zombies_esta_oleada = max(20, zombies_esta_oleada / 2)  # Mitad de zombies pero mínimo 10
	
	# Generar zombies
	for i in range(zombies_esta_oleada):
		if wave_active:  # Por si cancelamos la oleada
			await get_tree().create_timer(tiempo_entre_spawns).timeout
			spawn_zombie(wave_number)  # Pasamos el número de oleada
	
	# Esperar tiempo adicional si no es ronda de boss
	if wave_number != 5 and wave_number != 10:
		await get_tree().create_timer(tiempo_espera_final).timeout
		
		# Verificar zombies restantes
		if zombies_en_escena > 0:
			print("Quedan %d zombies por eliminar..." % zombies_en_escena)
			await get_tree().create_timer(5.0).timeout
	
	wave_active = false
	emit_signal("oleada_terminada")

func spawn_zombie(wave_number: int):
	# Calcular probabilidad ajustada por oleada
	var prob_actual = min(probabilidad_enemy2 + (wave_number - 1) * incremento_probabilidad_por_oleada, 0.8)  # Máximo 80%
	
	var zombie_instance
	if randf() < prob_actual:
		zombie_instance = zombie2_scene.instantiate()
		print("Spawneando Enemy2 (Oleada ", wave_number, ")")
	else:
		zombie_instance = zombie_scene.instantiate()
	
	if not zombie_instance:
		push_error("Error: No se pudo instanciar el zombie.")
		return
	
	# Conectar señales (ambos enemigos deben tener la misma señal)
	if zombie_instance.has_signal("enemy_muerto"):
		zombie_instance.connect("enemy_muerto", Callable(self, "_on_enemy_muerto"))
	
	add_child(zombie_instance)
	zombies_en_escena += 1
	
	await get_tree().process_frame
	var spawn_position = get_random_position_in_area()
	zombie_instance.global_transform.origin = spawn_position

func _on_enemy_muerto(puntos: int):
	zombies_en_escena -= 1
	# Aquí puedes manejar los puntos si lo necesitas

func _on_boss_derrotado():
	boss_active = false
	emit_signal("boss_derrotado")

func get_random_position_in_area() -> Vector3:
	if not spawn_area:
		return Vector3.ZERO

	var shape_node = spawn_area.find_child("CollisionShape3D")
	if not (shape_node is CollisionShape3D) or not (shape_node.shape is BoxShape3D):
		return spawn_area.global_transform.origin

	var box_size = shape_node.shape.size
	var spawn_x = randf_range(-box_size.x / 2, box_size.x / 2)
	var spawn_z = randf_range(-box_size.z / 2, box_size.z / 2)

	return spawn_area.global_transform.origin + Vector3(spawn_x, 0, spawn_z)
