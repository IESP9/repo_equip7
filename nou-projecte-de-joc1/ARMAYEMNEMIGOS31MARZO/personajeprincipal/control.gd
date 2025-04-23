extends Control  # Usamos Control para poder dibujar la mira

# Configuración de la mira
@export var line_color: Color = Color(0, 1, 1)  # Color de la cruz (rojo)
@export var line_width: int = 1  # Ancho de las líneas de la cruz
@export var cross_size: int = 10  # Tamaño de la cruz

# Método para dibujar la cruz (mira) en el centro de la pantalla
func _draw():
	var viewport_size = get_viewport().size  # Obtener el tamaño del viewport
	var center = Vector2(viewport_size.x, viewport_size.y) / 2  # Convertimos explicitamente a Vector2
	
	# Dibujamos la línea horizontal de la cruz
	draw_line(center + Vector2(-cross_size, 0), center + Vector2(cross_size, 0), line_color, line_width)
	# Dibujamos la línea vertical de la cruz
	draw_line(center + Vector2(0, -cross_size), center + Vector2(0, cross_size), line_color, line_width)

# No es necesario llamar a update(), ya que Godot se encarga de actualizar el dibujo
