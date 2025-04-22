extends Control

@export var siguiente_escena: String = "res://mainmenu.tscn"  # Ruta de la escena a cargar
@onready var progress_bar = $ProgressBar  # Referencia a la ProgressBar

func _ready():
	# Inicializa la ProgressBar
	progress_bar.value = 0  # Establece el valor inicial en 0
	progress_bar.max_value = 100  # Establece el valor máximo en 100

	# Simula el progreso de la carga
	simular_carga()

# Función para simular el progreso de la carga
func simular_carga():
	var tiempo_carga = 20.0  # Tiempo total de carga en segundos
	var incremento = 3.0  # Incremento del progreso en cada paso
	var tiempo_por_paso = tiempo_carga / (progress_bar.max_value / incremento)

	while progress_bar.value < progress_bar.max_value:
		progress_bar.value += incremento  # Incrementa el valor de la ProgressBar
		await get_tree().create_timer(tiempo_por_paso).timeout  # Espera un poco antes de continuar

	# Cuando la carga esté completa, cambia a la siguiente escena
	get_tree().change_scene_to_file(siguiente_escena)
