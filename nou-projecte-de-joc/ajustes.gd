extends Control

# Referencias a los nodos de la UI
@onready var volumen_slider = $HSlider
@onready var resolucion_option = $OptionButton
@onready var pantalla_completa_check = $CheckButton
@onready var guardar_salir_button = $Button  # Referencia al botón "Guardar y salir"

# Opciones de resolución (1920x1080 es la primera opción)
var resoluciones = [
	Vector2i(1920, 1080), # 1080p (primera opción)
	Vector2i(1280, 720),  # 720p
	Vector2i(2560, 1440)  # 1440p
]

# Ruta del archivo de configuración
const CONFIG_FILE = "user://ajustes.cfg"

func _ready():
	# Configurar el OptionButton con las resoluciones
	for resolucion in resoluciones:
		resolucion_option.add_item("%dx%d" % [resolucion.x, resolucion.y])

	# Cargar ajustes guardados (o aplicar valores predeterminados si no hay archivo)
	cargar_ajustes()

	# Conectar señales
	volumen_slider.value_changed.connect(_on_volumen_changed)
	resolucion_option.item_selected.connect(_on_resolucion_selected)
	pantalla_completa_check.toggled.connect(_on_pantalla_completa_toggled)
	guardar_salir_button.pressed.connect(_on_guardar_salir_pressed)  # Conectar el botón

# Función para cargar ajustes guardados (o aplicar valores predeterminados)
func cargar_ajustes():
	var config = ConfigFile.new()
	if config.load(CONFIG_FILE) == OK:
		# Cargar volumen
		volumen_slider.value = config.get_value("audio", "volumen", 1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volumen_slider.value))

		# Cargar resolución
		var resolucion_index = config.get_value("video", "resolucion_index", 0)  # 0 = 1920x1080 (primera opción)
		resolucion_option.selected = resolucion_index
		_on_resolucion_selected(resolucion_index)

		# Cargar pantalla completa
		var pantalla_completa = config.get_value("video", "pantalla_completa", true)  # true = Pantalla completa (predeterminada)
		pantalla_completa_check.set_pressed_no_signal(pantalla_completa)
		_on_pantalla_completa_toggled(pantalla_completa)
	else:
		# Aplicar valores predeterminados si no hay archivo de configuración
		volumen_slider.value = 1.0
		resolucion_option.selected = 0  # 1920x1080 (primera opción)
		pantalla_completa_check.set_pressed_no_signal(true)  # Pantalla completa activada
		_on_resolucion_selected(0)  # Aplicar resolución predeterminada
		_on_pantalla_completa_toggled(true)  # Aplicar pantalla completa predeterminada

# Función para guardar ajustes
func guardar_ajustes():
	var config = ConfigFile.new()

	# Guardar volumen
	config.set_value("audio", "volumen", volumen_slider.value)

	# Guardar resolución
	config.set_value("video", "resolucion_index", resolucion_option.selected)

	# Guardar pantalla completa
	config.set_value("video", "pantalla_completa", pantalla_completa_check.is_pressed())

	# Guardar el archivo de configuración
	config.save(CONFIG_FILE)

# Señal: Cambio de volumen
func _on_volumen_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

# Señal: Cambio de resolución
func _on_resolucion_selected(index: int):
	var resolucion = resoluciones[index]
	DisplayServer.window_set_size(resolucion)

	# Ajustar el modo de pantalla completa si está activado
	if pantalla_completa_check.is_pressed():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Señal: Cambio de pantalla completa
func _on_pantalla_completa_toggled(pressed: bool):
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Señal: Botón "Guardar y salir"
func _on_guardar_salir_pressed():
	guardar_ajustes()
	get_tree().change_scene_to_file("res://mainmenu.tscn")  # Cambiar a la escena principal
