extends CanvasLayer

@onready var panel = $Panel
@onready var continue_btn = $Panel/VBoxContainer/ContinueBtn
@onready var mainmenu_btn = $Panel/VBoxContainer/MainMenuBtn

var menu_abierto := false
var fisicas_pausadas := false

func _ready():
	panel.visible = false
	# Conexión directa de señales (más confiable que el editor)
	continue_btn.pressed.connect(_continuar)
	mainmenu_btn.pressed.connect(_ir_al_menu)
	
	# Configuración CRÍTICA para inputs
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	continue_btn.focus_mode = Control.FOCUS_ALL
	mainmenu_btn.focus_mode = Control.FOCUS_ALL

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		abrir_cerrar_menu()
		get_viewport().set_input_as_handled()

func abrir_cerrar_menu():
	menu_abierto = !menu_abierto
	panel.visible = menu_abierto
	
	# Control de pausa de físicas
	fisicas_pausadas = menu_abierto
	Engine.time_scale = 0.0 if menu_abierto else 1.0
	
	if menu_abierto:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		continue_btn.grab_focus()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _continuar():
	abrir_cerrar_menu()

func _ir_al_menu():
	# Restaurar las físicas antes de cambiar de escena
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://mainmenu.tscn")
