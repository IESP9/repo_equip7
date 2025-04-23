extends Node3D

# Señal para indicar que la oleada ha terminado
signal oleada_terminada

# Referencias a nodos y recursos
@onready var spawn_area: Node3D = $SpawnArea  # Asegurar que el nodo esté asignado correctamente
@onready var zombie_scene: PackedScene = preload("res://enemy.tscn")  # Cargar la escena del zombie

# Variables exportables para personalizar la oleada
@export var zombies_por_oleada: int = 5  # Número de zombies a generar por oleada
@export var tiempo_entre_spawns: float = 2.0  # Tiempo en segundos entre cada spawn

# Estado de la oleada
var wave_active = false  # Controla si la oleada ya comenzó

func _ready() -> void:
	# Verificar que el área de spawn esté asignada
	if not spawn_area:
		push_error("Error: spawn_area no está asignado.")
		return

# Función para iniciar la oleada de zombies
func start_wave() -> void:
	if wave_active:
		return  # Si ya comenzó, no volver a iniciar
	
	wave_active = true
	print("¡Iniciando oleada de zombies!")

	# Generar zombies en intervalos de tiempo
	for i in range(zombies_por_oleada):
		await get_tree().create_timer(tiempo_entre_spawns).timeout
		spawn_zombie()

	wave_active = false  # Reiniciar el estado de la oleada
	emit_signal("oleada_terminada")  # Emitir la señal

# Función para generar un zombie en una posición aleatoria
func spawn_zombie() -> void:
	var zombie = zombie_scene.instantiate()
	if not zombie:
		push_error("Error: No se pudo instanciar la escena del zombie.")
		return
	
	# Añadir el zombie al árbol de la escena
	add_child(zombie)
	
	# Esperar un frame para asegurarse de que el zombie esté completamente en el árbol de la escena
	await get_tree().process_frame
	
	# Obtener una posición aleatoria dentro del área de spawn
	var spawn_position = get_random_position_in_area()
	zombie.global_transform.origin = spawn_position

# Función para calcular una posición aleatoria dentro del área de spawn
func get_random_position_in_area() -> Vector3:
	if not spawn_area:
		push_error("Error: spawn_area no está asignado.")
		return Vector3.ZERO

	# Buscar el CollisionShape3D dentro del área de spawn
	var shape_node = spawn_area.find_child("CollisionShape3D")
	if not (shape_node is CollisionShape3D):
		push_error("Error: No se encontró CollisionShape3D dentro de spawn_area.")
		return spawn_area.global_transform.origin

	# Verificar que el CollisionShape3D tenga un BoxShape3D
	if not (shape_node.shape is BoxShape3D):
		push_error("Error: CollisionShape3D no tiene un BoxShape3D.")
		return spawn_area.global_transform.origin

	# Calcular una posición aleatoria dentro del área
	var box_size = shape_node.shape.size  # Usar `size` para BoxShape3D
	var spawn_x = randf_range(-box_size.x / 2, box_size.x / 2)
	var spawn_z = randf_range(-box_size.z / 2, box_size.z / 2)

	return spawn_area.global_transform.origin + Vector3(spawn_x, 0, spawn_z)
