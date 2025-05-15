extends Control

@onready var quit_button = $AtrasButton

func _ready():
	# Liberar el ratón y hacerlo visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	quit_button.pressed.connect(_on_quit_pressed)

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://creditos.tscn")  # Ajusta la ruta a tu escena de menú
