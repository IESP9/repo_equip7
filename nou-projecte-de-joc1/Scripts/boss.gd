extends Node3D  # O cualquier otro nodo adecuado

@onready var zombie_camera = $ZombieCamera  # Cámara del zombie
@onready var player_camera = $Player/CharacterBody3D/Head/player_Camera  # Cámara del jugador
@onready var anim_camera = $ZombieCamera/AnimationPlayer  # Animación de la cámara del zombie
@export var target_scene: String = "res://caffe.tscn"
@export var tiempo_espera = 0.1  # Tiempo de espera antes de cambiar la escena (en segundos)# AudioStreamPlayer3D del rugido del monstruo
@onready var transition_label = $Control/TransitionLabel  # Ruta al Label
@export var mensaje_transicion = "Cagaste"  # Texto que aparecerá
@export var tiempo_mensaje = 2.0  # Duración total del mensaje en pantalla
@export var tiempo_fade = 0.5  # Duración del efecto de desvanecimiento

func _ready():
	mostrar_mensaje(mensaje_transicion)  # Muestra el mensaje al iniciar
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

func mostrar_mensaje(texto: String):
	transition_label.text = texto  # Cambia el texto
	transition_label.modulate.a = 0.0  # Hace que el texto sea invisible al inicio
	transition_label.show()  # Muestra el Label en la pantalla

	var tween = create_tween()  # Crea el tween para animar
	tween.tween_property(transition_label, "modulate:a", 1.0, tiempo_fade)  # Fade-in
	await get_tree().create_timer(tiempo_mensaje).timeout  # Espera tiempo_mensaje segundos

	var tween_out = create_tween()  # Nuevo tween para el fade-out
	tween_out.tween_property(transition_label, "modulate:a", 0.0, tiempo_fade)  # Fade-out
	await tween_out.finished  # Espera a que termine el fade-out

	transition_label.hide()  # Oculta el mensaje después de desvanecerse


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
