extends Control

# Referencias a los nodos de la UI
@onready var panel = $ColorRect
@onready var label = $ColorRect/Label
@onready var mensaje_interaccion = $MensajeInteraccion

func _ready():
	# Configurar visibilidad inicial
	panel.visible = false
	mensaje_interaccion.visible = false
	add_to_group("UI")  # Añadir la UI al grupo "UI"

	# Mensaje de depuración para confirmar que la UI se ha inicializado
	print("UI inicializada correctamente.")

# Función para mostrar la nota
func mostrar_nota(texto: String):
	label.text = texto
	panel.visible = true
	print("Nota mostrada: ", texto)  # Mensaje de depuración

# Función para ocultar la nota
func ocultar_nota():
	panel.visible = false
	print("Nota ocultada")  # Mensaje de depuración

# Función para mostrar el mensaje de interacción
func mostrar_mensaje_interaccion():
	mensaje_interaccion.text = "Tocar [E] para leer el mensaje"
	mensaje_interaccion.visible = true
	print("Mensaje de interacción mostrado")  # Mensaje de depuración

# Función para ocultar el mensaje de interacción
func ocultar_mensaje_interaccion():
	mensaje_interaccion.visible = false
	print("Mensaje de interacción ocultado")  # Mensaje de depuración
