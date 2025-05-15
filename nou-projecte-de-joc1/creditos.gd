extends Control

@export var scroll_speed: float = 50.0  # Velocidad de desplazamiento (ajustable desde el editor)
@onready var credits_container: VBoxContainer = $CreditsContainer
@onready var timer: Timer = $Timer

func _ready():
	# Asegurarse de que el contenedor esté en la posición inicial
	credits_container.position.y = get_viewport_rect().size.y
	# Iniciar el desplazamiento
	timer.start()

func _process(delta):
	# Mover los créditos hacia arriba
	credits_container.position.y -= scroll_speed * delta
	
	# Si llegamos al final, volver al menú principal
	if credits_container.position.y + credits_container.size.y < 0:
		return_to_menu()

func return_to_menu():
	get_tree().change_scene_to_file("res://mainmenu.tscn")  # Cambia a tu escena de menú
