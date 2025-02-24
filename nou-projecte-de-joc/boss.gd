extends Node3D  # O cualquier otro nodo adecuado

@onready var zombie_camera = $ZombieCamera  # Cámara del zombie
@onready var player_camera = $Player/CharacterBody3D/Head/player_Camera  # Cámara del jugador
@onready var anim_camera = $ZombieCamera/AnimationPlayer  # Animación de la cámara del zombie
@export var target_scene: String = "res://caffe.tscn"
@export var tiempo_espera = 0.1  # Tiempo de espera antes de cambiar la escena (en segundos)
@onready var monster_roar = $MonsterRoar4  # AudioStreamPlayer3D del rugido del monstruo

func _ready():
	monster_roar.play()
	iniciar_camara_zombie()  # Inicia con la cámara del zombie
	anim_camera.play("seguir")  # Reproduce la animación de la cámara del zombie
	# Espera a que la animación termine
	await anim_camera.animation_finished
	cambiar_a_camara_jugador()
	
	# Espera 4 segundos y cambia la escena
	await esperar(tiempo_espera)
	cambiar_escena()

# Cambia a la cámara del zombie al inicio
func iniciar_camara_zombie():
	zombie_camera.current = true  # Activa la cámara del zombie
	player_camera.current = false  # Desactiva la cámara del jugador

# Cambia a la cámara del jugador
func cambiar_a_camara_jugador():
	zombie_camera.current = false  # Desactiva la cámara del zombie
	player_camera.current = true  # Activa la cámara del jugador

# Función para esperar un tiempo específico
func esperar(segundos: float):
	return await get_tree().create_timer(segundos).timeout

# Cambia la escena después del tiempo de espera
func cambiar_escena():
	get_tree().call_deferred("change_scene_to_file", target_scene)
