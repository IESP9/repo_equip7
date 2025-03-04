extends Node3D

@onready var spawn_area = $SpawnArea  # Asegúrate de que el nodo se llame "SpawnArea"
@onready var zombie_scene = preload("res://zombie.tscn")  # Ruta de la escena del zombie
@export var zombies_por_oleada: int = 5  # Número de zombies a generar

func _ready():
	if spawn_area == null:
		print("Error: spawn_area no está asignado.")
		return  # Si no hay spawn_area, no hacer nada
	start_wave()  # Inicia la oleada

# Genera una oleada de zombies
func start_wave():
	for i in range(zombies_por_oleada):
		spawn_zombie()

# Genera un solo zombie en una posición aleatoria dentro del área de spawn
func spawn_zombie():
	var zombie = zombie_scene.instantiate()
	var spawn_position = get_random_position_in_area()
	zombie.position = spawn_position
	add_child(zombie)

# Calcula una posición aleatoria dentro del área de spawn
func get_random_position_in_area() -> Vector3:
	if spawn_area == null:
		print("Error: spawn_area no está asignado.")
		return Vector3.ZERO

	var shape_node = spawn_area.find_child("CollisionShape3D")
	if shape_node == null or not (shape_node is CollisionShape3D):
		print("Error: No se encontró CollisionShape3D dentro de spawn_area.")
		return spawn_area.global_transform.origin  # Usa la posición base del área

	# Asegurar que el shape es un BoxShape3D
	if not (shape_node.shape is BoxShape3D):
		print("Error: CollisionShape3D no tiene un BoxShape3D.")
		return spawn_area.global_transform.origin

	# Obtener el tamaño del área de spawn
	var box_size = shape_node.shape.extents * 2
	var spawn_x = randf_range(-box_size.x / 2, box_size.x / 2)
	var spawn_z = randf_range(-box_size.z / 2, box_size.z / 2)

	# Devolver la posición aleatoria dentro del spawn_area
	return spawn_area.global_transform.origin + Vector3(spawn_x, 0, spawn_z)
