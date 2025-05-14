extends Node

signal puntos_actualizados(puntos_totales)
signal mejora_aplicada(nombre_mejora)

var player: Node3D  # Almacenará la referencia al jugador
var loading_screen = preload("res://LoadingScreen.tscn").instantiate()
var puntos_totales: int = 0

func _ready():
	get_tree().root.call_deferred("add_child", loading_screen)

func change_scene_with_loading(target_scene_path: String):
	loading_screen.load_scene(target_scene_path)

func agregar_puntos(cantidad: int):
	puntos_totales += cantidad
	puntos_actualizados.emit(puntos_totales)
	print("Puntos totales: ", puntos_totales)

func canjear_puntos(costo: int) -> bool:
	if puntos_totales >= costo:
		puntos_totales -= costo
		puntos_actualizados.emit(puntos_totales)
		return true
	return false
