extends Node3D

@onready var Vida : Label = $CanvasLayer/Vida  # Etiqueta de vida en el CanvasLayer
@onready var Balas : Label = $CanvasLayer/Balas  # Etiqueta de balas en el CanvasLayer

var player : CharacterBody3D = null

func _ready():
	# Obtener referencia al jugador si ya está en la escena
	player = $CharacterBody3D  # Usamos el nodo existente del jugador
	update_ui()

# Función para actualizar la UI con la vida y las balas
func update_ui():
	if player:  # Verificamos si el jugador está cargado
		var stats = player.get_player_stats()  # Obtenemos las estadísticas del jugador
		Vida.text = "Vida: " + str(stats["life"]) + " / " + str(player.max_life)
		Balas.text = "Balas: " + str(stats["ammo"]) + " / " + str(player.max_ammo)

# Puedes actualizar la UI constantemente en el _process si es necesario
func _process(delta):
	update_ui()  # Actualizamos cada frame (si es necesario)
