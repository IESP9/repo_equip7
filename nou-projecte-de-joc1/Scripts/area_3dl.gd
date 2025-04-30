extends Area3D

@export var target_scene: String = "res://primermapa.tscn"
var loading_screen = null

func _ready():
	# Precarga la pantalla de carga
	call_deferred("_prepare_loading_screen")
	
	# Conexión segura de señal
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _prepare_loading_screen():
	loading_screen = preload("res://LoadingScreen.tscn").instantiate()
	get_tree().root.add_child(loading_screen)

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D and loading_screen:
		# Verificación adicional de la escena
		if ResourceLoader.exists(target_scene):
			loading_screen.start_loading(target_scene)
		else:
			push_error("La escena objetivo no existe: ", target_scene)
