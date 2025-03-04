extends Node3D  

@onready var transition_label = $Control/TransitionLabel  # Ruta al Label
@export var mensaje_transicion = "Pasillo Principal"  # Texto que aparecerá
@export var tiempo_mensaje = 2.0  # Duración total del mensaje en pantalla
@export var tiempo_fade = 0.5  # Duración del efecto de desvanecimiento

func _ready():
	mostrar_mensaje(mensaje_transicion)  # Muestra el mensaje al iniciar

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
