extends CanvasLayer

@onready var Vida : Label = $Vida
@onready var Balas : Label = $Balas 

# Referencia al jugador
var player : CharacterBody3D = null

func _ready():
	# Obtener la referencia al jugador desde la escena principal
	player = get_node("/root/Node3D/CharacterBody3D")  # Usamos la ruta correcta para acceder al jugador
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
