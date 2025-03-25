extends Control

@onready var play_button = $SurvivalButton
@onready var options_button = $M_abiertoButton
@onready var quit_button = $AtrasButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://historia.tscn")  # Cambia a la escena del juego

func _on_options_pressed():
	get_tree().change_scene_to_file("res://mundo_abierto.tscn")  # Cambia a la escena del ajustes

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://mainmenu.tscn")  # Cambia a la escena del ajustes
