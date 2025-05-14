extends Control

@onready var label_puntos = $Label

func _ready():
	Global.puntos_actualizados.connect(actualizar_puntos)
	actualizar_puntos(Global.puntos_totales)

func actualizar_puntos(puntos: int):
	label_puntos.text = "Puntos: %d" % puntos
