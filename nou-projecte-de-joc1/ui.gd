extends Control

# Referencias a los nodos de la UI
@onready var panel = $ColorRect
@onready var label = $ColorRect/Label
@onready var mensaje_interaccion = $MensajeInteraccion
@onready var mensaje_bloqueo = $MensajeBloqueo
@onready var mision_texto = $MisionTexto
@onready var mensaje_bloqueo_timer = $MensajeBloqueoTimer

# Variables de misión
var mision_actual = {
	"objetivo": "Revisa la sala en busca de pistas",
	"completada": false
}

func _ready():
	# Configurar visibilidad inicial
	panel.visible = false
	mensaje_interaccion.visible = false
	mensaje_bloqueo.visible = false
	
	# Solo mostrar misión si estamos en office.tscn
	if get_tree().current_scene.scene_file_path == "res://office.tscn":
		mision_texto.text = mision_actual["objetivo"]
		mision_texto.visible = true
	else:
		mision_texto.visible = false
	
	add_to_group("UI")
	mensaje_bloqueo_timer.timeout.connect(_on_mensaje_bloqueo_timeout)

func mostrar_nota(texto: String):
	label.text = texto
	panel.visible = true

func ocultar_nota():
	panel.visible = false

func mostrar_mensaje_interaccion(mensaje: String = "Presiona E para leer"):
	mensaje_interaccion.text = mensaje
	mensaje_interaccion.visible = true

func ocultar_mensaje_interaccion():
	mensaje_interaccion.visible = false

func mostrar_mensaje_bloqueo(mensaje: String = "Debes revisar la sala en busca de pistas"):
	mensaje_bloqueo.text = mensaje
	mensaje_bloqueo.visible = true
	mensaje_bloqueo_timer.start(3.0)

func completar_mision():
	if get_tree().current_scene.scene_file_path == "res://office.tscn":
		mision_actual["completada"] = true
		mision_texto.text = mision_actual["objetivo"] + " (Completada)"
		mision_texto.add_theme_color_override("font_color", Color.GREEN)

func _on_mensaje_bloqueo_timeout():
	mensaje_bloqueo.visible = false

func _input(event):
	if panel.visible and event.is_action_pressed("ui_cancel"):
		ocultar_nota()
