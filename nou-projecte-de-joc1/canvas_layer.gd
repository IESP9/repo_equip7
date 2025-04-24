extends CanvasLayer

@onready var Vida: Label = $Vida
@onready var Balas: Label = $Balas
@onready var Recargar: Label = $Recargar  # Asegúrate de que el nodo existe en tu escena

# Referencia al jugador
var player: CharacterBody3D = null
var waiting_for_reload: bool = false

func _ready():
	# Obtener referencia al jugador
	player = get_node("/root/Node3D/CharacterBody3D")
	
	# Configurar estado inicial
	Recargar.visible = false
	update_ui()

func update_ui():
	if player:
		var stats = player.get_player_stats()
		Vida.text = "Vida: " + str(stats["life"]) + " / " + str(player.max_life)
		Balas.text = "Balas: " + str(stats["ammo"]) + " / " + str(player.max_ammo)
		
		# Mostrar mensaje de recarga si no hay balas
		if stats["ammo"] <= 0 and not waiting_for_reload:
			show_reload_message()
		elif stats["ammo"] > 0 and waiting_for_reload:
			hide_reload_message()

func show_reload_message():
	Recargar.text = "Presiona [R] para recargar"
	Recargar.visible = true
	waiting_for_reload = true

func hide_reload_message():
	Recargar.visible = false
	waiting_for_reload = false

func _input(event):
	if waiting_for_reload and event.is_action_pressed("reload"):
		# Intenta recargar (el jugador debe tener este método)
		if player.has_method("reload"):
			player.reload()
		hide_reload_message()

func _process(delta):
	update_ui()
