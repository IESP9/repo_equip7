extends CanvasLayer

@onready var panel = $ColorRect
@onready var continue_button = $ColorRect/ContinueBtn
@onready var options_button = $ColorRect/OptionsBtn
@onready var quit_button = $ColorRect/QuitBtn

var is_paused = false

func _ready():
	# Configuración inicial
	panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Verificar que todos los botones existen
	if not continue_button or not options_button or not quit_button:
		printerr("¡Error! Uno o más botones no fueron encontrados")
		return
	
	# Configurar botones
	setup_button(continue_button, _on_continue_pressed)
	setup_button(options_button, _on_options_pressed)
	setup_button(quit_button, _on_quit_pressed)

func setup_button(button: Button, callback: Callable):
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(callback)
	button.mouse_entered.connect(_on_button_hover.bind(button))

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Tecla ESC
		toggle_pause()

func _on_button_hover(button: Button):
	if is_paused:
		button.grab_focus()

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	panel.visible = is_paused
	
	# Manejo del ratón
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED)
	
	if is_paused:
		continue_button.grab_focus()  # Enfocar el botón continuar al abrir

# Funciones específicas para cada botón
func _on_continue_pressed():
	if is_paused:
		toggle_pause()

func _on_options_pressed():
	if is_paused:
		print("Opciones presionado")
		# get_tree().change_scene_to_file("res://opciones.tscn")

func _on_quit_pressed():
	if is_paused:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://mainmenu.tscn")
