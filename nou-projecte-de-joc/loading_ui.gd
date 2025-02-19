extends CanvasLayer

@onready var label = $ColorRect/Label

func show_loading():
	visible = true
	label.text = "Cargando..."

func hide_loading():
	await get_tree().create_timer(0.5).timeout  # Pequeño retraso para que la transición se vea
	visible = false
