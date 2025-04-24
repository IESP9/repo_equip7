extends Control

# Referencias a botones
@onready var play_button: Button = $SurvivalButton
@onready var quit_button: Button = $AtrasButton

func _ready():
	# Configurar modo ratón para menús
	_set_menu_mouse_mode()
	
	# Conectar señales de botones
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Conectar hover para feedback visual
	play_button.mouse_entered.connect(_on_button_hover.bind(play_button))
	quit_button.mouse_entered.connect(_on_button_hover.bind(quit_button))

func _set_menu_mouse_mode():
	# Hacer visible y libre el ratón
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _set_shooter_mouse_mode():
	# Ocultar y capturar ratón para shooter
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_button_hover(button: Button):
	# Efecto visual al pasar el ratón
	button.grab_focus()
	button.modulate = Color(1.1, 1.1, 1.1)

func _on_play_pressed():
	# Efecto al pulsar
	play_button.modulate = Color(0.9, 0.9, 0.9)
	await get_tree().create_timer(0.1).timeout
	
	# Cambiar a modo shooter antes de cargar la escena
	_set_shooter_mouse_mode()
	get_tree().change_scene_to_file("res://mapa2.tscn")

func _on_quit_pressed():
	# Efecto al pulsar
	quit_button.modulate = Color(0.9, 0.9, 0.9)
	await get_tree().create_timer(0.1).timeout
	
	# Mantener modo ratón para menús
	_set_menu_mouse_mode()
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _notification(what):
	# Asegurar que el ratón se muestra correctamente al pausar/volver
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		if get_tree().paused or visible:
			_set_menu_mouse_mode()
