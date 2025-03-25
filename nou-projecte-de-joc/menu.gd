extends Control

@onready var play_button = $PlayButton
@onready var options_button = $OptionsButton
@onready var quit_button = $QuitButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://menu2.tscn")  # Cambia a la escena del juego

func _on_options_pressed():
	get_tree().change_scene_to_file("res://ajustes.tscn")  # Cambia a la escena del ajustes

func _on_quit_pressed():
	get_tree().quit()  # Cierra el juego
