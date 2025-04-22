extends Node3D

class_name WaveSpawner

# Señales
signal wave_started(wave_number: int, zombies_count: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

# Configuración
@export var initial_zombies: int = 5
@export var zombies_increase: int = 5
@export var max_waves: int = 5
@export var spawn_delay: float = 2.0
@export var time_between_waves: float = 10.0

@onready var spawn_area: Node3D = $SpawnArea
@onready var zombie_scene: PackedScene = preload("res://enemy.tscn")

# Estado
var current_wave: int = 0
var zombies_to_spawn: int = 0
var zombies_alive: int = 0
var spawn_timer: Timer
var wave_timer: Timer
var is_spawning: bool = false

func _ready():
	# Crear timers
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	
	wave_timer = Timer.new()
	wave_timer.one_shot = true
	add_child(wave_timer)
	
	# Conectar señales
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_start_next_wave)

func start_wave_system():
	current_wave = 0
	_start_next_wave()

func _start_next_wave():
	if current_wave >= max_waves:
		all_waves_completed.emit()
		return
	
	current_wave += 1
	zombies_to_spawn = initial_zombies + (current_wave - 1) * zombies_increase
	zombies_alive = 0
	
	wave_started.emit(current_wave, zombies_to_spawn)
	print("Iniciando oleada ", current_wave, " con ", zombies_to_spawn, " zombies")
	
	_start_spawning()

func _start_spawning():
	is_spawning = true
	_spawn_zombie()

func _spawn_zombie():
	if zombies_to_spawn <= 0:
		is_spawning = false
		return
	
	var zombie = zombie_scene.instantiate()
	add_child(zombie)
	
	# Esperar un frame para asegurar que el zombie está listo
	await get_tree().process_frame
	
	zombie.global_transform.origin = get_random_position_in_area()
	zombie.tree_exiting.connect(_on_zombie_died)
	
	zombies_to_spawn -= 1
	zombies_alive += 1
	
	if zombies_to_spawn > 0:
		spawn_timer.start(spawn_delay)

func _on_spawn_timer_timeout():
	if is_spawning:
		_spawn_zombie()

func _on_zombie_died():
	zombies_alive -= 1
	if zombies_alive <= 0 and not is_spawning:
		_complete_wave()

func _complete_wave():
	wave_completed.emit(current_wave)
	print("Oleada ", current_wave, " completada!")
	
	if current_wave < max_waves:
		print("Siguiente oleada en ", time_between_waves, " segundos")
		wave_timer.start(time_between_waves)
	else:
		all_waves_completed.emit()

func get_random_position_in_area() -> Vector3:
	if not spawn_area:
		return global_transform.origin
	
	var shape = spawn_area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if not shape or not shape.shape is BoxShape3D:
		return spawn_area.global_transform.origin
	
	var box = shape.shape as BoxShape3D
	var extents = box.size / 2.0
	var pos = spawn_area.global_transform.origin
	pos.x += randf_range(-extents.x, extents.x)
	pos.z += randf_range(-extents.z, extents.z)
	
	return pos
