extends Node3D

# Referencias a nodos
@onready var wave_label: Label = $Control/Label
@export var spawn_controller: Node3D  # Asignar manualmente desde el editor

# Estado de la oleada
var wave_started = false  
# En mapa2.gd
func _ready():
	# Configurar el texto inicial del label
		# Buscar el nodo Player en la escena
	var player_node = get_node_or_null("Player")
	if player_node:
		Global.player = player_node  # Asignar la referencia del jugador al singleton
	else:
		push_error("Error: No se encontró al jugador en la escena.")
	wave_label.text = "¡Los zombies se acercan! Presiona [E] para comenzar la oleada"
	wave_label.visible = true  

	# Verificar que el SpawnController esté asignado
	if not spawn_controller:
		push_error("Error: SpawnController no está asignado.")

# Función para manejar la entrada del jugador
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_E and not wave_started:
		wave_started = true
		wave_label.visible = true  
		wave_label.text = "¡La oleada ha comenzado!"  # Actualizar el texto del label
		
		# Iniciar la oleada si el SpawnController está asignado
		if spawn_controller:
			spawn_controller.start_wave()
			
			# Esperar 3 segundos antes de ocultar el mensaje
			await get_tree().create_timer(3.0).timeout
			wave_label.visible = false  # Ocultar el Label
			
			# Esperar a que termine la oleada
			await spawn_controller.oleada_terminada  # Necesitas agregar una señal en SpawnController
			wave_started = false  # Reiniciar el estado de la oleada
		else:
			push_error("Error: SpawnController no está asignado")
