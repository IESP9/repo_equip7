extends Node3D

@onready var spawn_area = $SpawnArea  # Asegúrate de que el nodo se llame "SpawnArea"
@onready var zombie_scene = preload("res://zombie.tscn")  # Ruta de la escena del zombie
@export var zombies_por_oleada: int = 5  # Número de zombies a generar
@export var tiempo_entre_zombies: float = 1.0  # Tiempo entre cada spawn (en segundos)

@export var boton_oleada: String = "start_wave"  # La acción de entrada para empezar la oleada

var is_wave_active: bool = false  # Bandera para evitar múltiples oleadas simultáneas

func _ready():
	if spawn_area == null:
		print("Error: spawn_area no está asignado.")
		return  # Si no hay spawn_area, no hacer nada
	print("Presiona el botón para empezar la oleada.")

func _process(delta):
	if Input.is_action_just_pressed(boton_oleada) and not is_wave_active:  # Evitar múltiples oleadas
		print("¡Iniciando oleada!")
		is_wave_active = true
		await start_wave()  # Esperar a que la oleada termine
		is_wave_active = false

func start_wave():
	for i in range(zombies_por_oleada):
		spawn_zombie()
		await get_tree().create_timer(tiempo_entre_zombies).timeout  # Espera antes de spawn el siguiente

func spawn_zombie():
	var zombie = zombie_scene.instantiate()
	var spawn_position = get_random_position_in_area()
	zombie.position = spawn_position
	add_child(zombie)

func get_random_position_in_area() -> Vector3:
	if spawn_area == null:
		print("Error: spawn_area no está asignado.")
		return Vector3.ZERO

	var shape_node = spawn_area.find_child("CollisionShape3D")
	if shape_node == null or not (shape_node is CollisionShape3D):
		print("Error: No se encontró CollisionShape3D dentro de spawn_area.")
		return spawn_area.global_transform.origin  # Usa la posición base del área

	if not (shape_node.shape is BoxShape3D):
		print("Error: CollisionShape3D no tiene un BoxShape3D.")
		return spawn_area.global_transform.origin

	var box_size = shape_node.shape.size  # Usar 'size' en lugar de 'extents * 2'
	var spawn_x = randf_range(-box_size.x / 2, box_size.x / 2)
	var spawn_z = randf_range(-box_size.z / 2, box_size.z / 2)

	return spawn_area.global_transform.origin + Vector3(spawn_x, 0, spawn_z)
