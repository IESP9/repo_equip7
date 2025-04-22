extends Area3D

@export var mensaje_bloqueo: String = "Debes ir a la cafeteria antes de salir"
@export var tiempo_mensaje: float = 3.0

var timer_bloqueo: Timer
var jugador: CharacterBody3D  # Almacenar referencia al jugador

func _ready():
	# Configurar timer
	timer_bloqueo = Timer.new()
	add_child(timer_bloqueo)
	timer_bloqueo.timeout.connect(_ocultar_mensaje)
	
	# Conectar señal de detección
	body_entered.connect(_on_body_entered)
	print("Área de mensaje lista. Esperando jugador...")

func _on_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Player"):
		print("¡Jugador detectado! Mostrando mensaje...")
		jugador = body  # Guardar referencia
		_mostrar_mensaje()

func _mostrar_mensaje():
	if jugador:
		# Acceder directamente al Label
		var label = jugador.get_node("UI/MensajeBloqueo2")
		if label:
			print("Mostrando mensaje en el Label")
			label.text = mensaje_bloqueo
			label.show()
			timer_bloqueo.start(tiempo_mensaje)
		else:
			printerr("ERROR: No se encontró MensajeBloqueo2")

func _ocultar_mensaje():
	if jugador:
		var label = jugador.get_node("UI/MensajeBloqueo2")
		if label:
			print("Ocultando mensaje")
			label.hide()
