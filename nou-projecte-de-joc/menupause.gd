extends CanvasLayer

# Variables explícitas para cada elemento del menú
@onready var pause_panel: ColorRect = $ColorRect
@onready var continue_button: Button = $ColorRect/VBoxContainer/Continuar
@onready var config_button: Button = $ColorRect/VBoxContainer/Configuracion
@onready var controls_button: Button = $ColorRect/VBoxContainer/Controles
@onready var quit_button: Button = $ColorRect/VBoxContainer/SalirAlMenuPrincipal

var game_paused := false

func _ready():
	pause_panel.visible = false
	
	# Conectar señales de botones mediante código (opcional)
	continue_button.pressed.connect(_on_continue_pressed)
	config_button.pressed.connect(_on_config_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Enfocar el primer botón para navegación con teclado/mando
	continue_button.grab_focus()

func _input(event):
	if event.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()

func toggle_pause_menu():
	game_paused = !game_paused
	
	pause_panel.visible = game_paused
	get_tree().paused = game_paused
	
	if game_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		continue_button.grab_focus()  # Reenfocar al abrir menú
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Funciones de señal para cada botón
func _on_continue_pressed():
	toggle_pause_menu()

func _on_config_pressed():
	# Implementar lógica de configuración
	print("Configuración presionada")

func _on_controls_pressed():
	# Implementar vista de controles
	print("Controles presionados")

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
