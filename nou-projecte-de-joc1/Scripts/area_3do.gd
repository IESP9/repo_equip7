extends Area3D

@export var target_scene: String = "res://pasillo2.tscn"
@export var requiere_nota: bool = true
@export var mensaje_bloqueo: String = "Debes encontrar y leer la nota antes de salir"
@export var tiempo_mensaje: float = 3.0

var timer_bloqueo: Timer

func _ready():
	# Crear el timer dinámicamente si no existe
	if not has_node("Timer"):
		timer_bloqueo = Timer.new()
		timer_bloqueo.name = "Timer"
		add_child(timer_bloqueo)
		timer_bloqueo.timeout.connect(_ocultar_mensaje_bloqueo)
	else:
		timer_bloqueo = $Timer
		timer_bloqueo.timeout.connect(_ocultar_mensaje_bloqueo)

func _on_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Player"):
		if requiere_nota and not body.ha_leido_nota:
			_mostrar_mensaje_bloqueo(body)
		else:
			get_tree().change_scene_to_file(target_scene)

func _mostrar_mensaje_bloqueo(jugador):
	var ui = jugador.get_node("UI")
	if ui and ui.has_method("mostrar_mensaje_bloqueo"):
		ui.mostrar_mensaje_bloqueo(mensaje_bloqueo)
		timer_bloqueo.start(tiempo_mensaje)
	
	# Efecto de sonido opcional
	if has_node("AudioStreamPlayer3D"):
		$AudioStreamPlayer3D.play()

func _ocultar_mensaje_bloqueo():
	# El mensaje se oculta automáticamente por el timer en la UI
	pass
