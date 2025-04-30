extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var status_label: Label = $Label

var target_scene: PackedScene
const MAX_WAIT_TIME := 8.0  # Aumentado a 8 segundos
var current_wait_time := 0.0

func _ready():
	hide()

func start_loading(scene_path: String):
	show()
	progress_bar.value = 0
	status_label.text = "Cargando 0%"
	current_wait_time = 0.0
	
	# Verificación adicional de la escena
	if not ResourceLoader.exists(scene_path):
		status_label.text = "Error: Escena no existe"
		return
	
	# Forzar redibujado
	await get_tree().process_frame
	
	# Carga con verificación mejorada
	_load_scene_safely(scene_path)

func _load_scene_safely(scene_path: String):
	var loader = ResourceLoader.load_threaded_request(scene_path)
	
	# Verificación periódica mejorada
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
		current_wait_time += get_process_delta_time()
		
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				var percent = int(progress[0] * 100)
				progress_bar.value = percent
				status_label.text = "Cargando %d%%" % percent
				
				if current_wait_time >= MAX_WAIT_TIME:
					_load_directly(scene_path)
					return
					
				await get_tree().create_timer(0.05).timeout
				
			ResourceLoader.THREAD_LOAD_LOADED:
				var scene = ResourceLoader.load_threaded_get(scene_path)
				if scene:
					_change_scene_safely(scene)
				else:
					_load_directly(scene_path)
				return
				
			_:
				_load_directly(scene_path)
				return

func _load_directly(scene_path: String):
	status_label.text = "Carga directa..."
	var scene = load(scene_path)
	if scene:
		_change_scene_safely(scene)
	else:
		status_label.text = "Error crítico de carga"
		progress_bar.value = 0

func _change_scene_safely(scene: PackedScene):
	progress_bar.value = 100
	status_label.text = "¡Listo!"
	
	# Espera mínima para visualización
	await get_tree().create_timer(0.5).timeout
	
	# Cambio de escena con protección
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)
	get_tree().current_scene = instance
	
	# Limpieza
	queue_free()
