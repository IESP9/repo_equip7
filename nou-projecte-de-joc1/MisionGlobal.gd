extends Node

signal mision_actualizada(texto_mision)

var mision_activa: bool = false
var mision_completada: bool = false

func activar_mision():
	mision_activa = true
	emit_signal("mision_actualizada", "Misión: Sal de la Oficina 0/1")
	print("Misión activada: Salir de la oficina")

func completar_mision():
	if mision_activa and not mision_completada:
		mision_completada = true
		emit_signal("mision_actualizada", "Misión: Sal de la Oficina 1/1")
		print("Misión completada: Has salido de la oficina")
	else:
		print("No hay misión activa para completar")
