extends CanvasLayer

@onready var vida_label: Label = $VidaLabel
@onready var balas_label: Label = $BalasLabel
@onready var recargar_label: Label = $RecargarLabel

# Colores
const COLOR_VIDA := Color("#4CAF50")  # Verde
const COLOR_BALAS := Color("#2196F3") # Azul
const COLOR_ALERTA := Color("#FF5722") # Naranja
const COLOR_TEXTO := Color("#FFFFFF") # Blanco
const COLOR_FONDO := Color(0.05, 0.05, 0.05, 0.85)

# Configuración
const MARGIN := 20
const ELEMENT_HEIGHT := 40
const MIN_ELEMENT_WIDTH := 220
const FONT_SIZE := 18
const CORNER_RADIUS := 8

var player: CharacterBody3D = null

func _ready():
	# Buscar al jugador
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	if player == null:
		player = get_node_or_null("/root/Node3D/CharacterBody3D") as CharacterBody3D
		if player == null:
			push_error("No se pudo encontrar el nodo del jugador")
			return
	
	recargar_label.visible = false
	
	# Conectar señales del jugador
	if player.has_signal("stats_updated"):
		player.stats_updated.connect(update_ui)
	if player.has_signal("player_died"):
		player.player_died.connect(on_player_died)
	
	# Configurar estilos primero
	_configurar_estilos()
	
	# Configurar posiciones después de que los estilos estén aplicados
	call_deferred("_setup_ui_positions")
	
	# Conectar señal de redimensionamiento
	get_viewport().connect("size_changed", _on_viewport_resized)
	
	# Actualizar UI
	update_ui(_get_player_life(), _get_player_ammo())

func _on_viewport_resized():
	_setup_ui_positions()

func _get_player_life() -> int:
	return player.current_life if "current_life" in player else 0

func _get_player_ammo() -> int:
	return player.current_ammo if "current_ammo" in player else 0

func _get_player_max_life() -> int:
	return player.max_life if "max_life" in player else _get_player_life()

func _get_player_max_ammo() -> int:
	return player.max_ammo if "max_ammo" in player else _get_player_ammo()

func _setup_ui_positions():
	# Asegurar que los labels tengan su tamaño calculado
	for label in [vida_label, balas_label, recargar_label]:
		label.reset_size()
	
	# Vida y Balas arriba a la izquierda
	vida_label.position = Vector2(MARGIN, MARGIN)
	balas_label.position = Vector2(MARGIN, MARGIN + ELEMENT_HEIGHT + 5)
	
	# Recargar - centrado horizontal y abajo
	var viewport_size = get_viewport().size
	var text_width = recargar_label.get_combined_minimum_size().x
	var label_width = max(MIN_ELEMENT_WIDTH, text_width + 40)  # Ancho mínimo + margen
	
	recargar_label.size.x = label_width
	recargar_label.position = Vector2(
		(viewport_size.x - label_width) / 2,
		viewport_size.y - ELEMENT_HEIGHT - MARGIN
	)

func _configurar_estilos():
	var estilo_base = StyleBoxFlat.new()
	estilo_base.bg_color = COLOR_FONDO
	estilo_base.border_color = Color(1, 1, 1, 0.3)
	estilo_base.border_width_left = 2
	estilo_base.border_width_right = 2
	estilo_base.border_width_top = 2
	estilo_base.border_width_bottom = 2
	estilo_base.corner_radius_top_left = CORNER_RADIUS
	estilo_base.corner_radius_top_right = CORNER_RADIUS
	estilo_base.corner_radius_bottom_right = CORNER_RADIUS
	estilo_base.corner_radius_bottom_left = CORNER_RADIUS
	estilo_base.content_margin_left = 15
	estilo_base.content_margin_right = 15
	
	# Estilo para vida
	var estilo_vida = estilo_base.duplicate()
	estilo_vida.border_color = COLOR_VIDA
	_configure_label_style(vida_label, estilo_vida, COLOR_VIDA, FONT_SIZE)
	
	# Estilo para balas
	var estilo_balas = estilo_base.duplicate()
	estilo_balas.border_color = COLOR_BALAS
	_configure_label_style(balas_label, estilo_balas, COLOR_BALAS, FONT_SIZE)
	
	# Estilo para recarga (más llamativo)
	var estilo_recarga = estilo_base.duplicate()
	estilo_recarga.bg_color = Color(0.15, 0.05, 0.05, 0.9)
	estilo_recarga.border_color = COLOR_ALERTA
	estilo_recarga.border_width_top = 3
	estilo_recarga.border_width_bottom = 3
	_configure_label_style(recargar_label, estilo_recarga, COLOR_ALERTA, FONT_SIZE + 2, true)
	recargar_label.text = "PRESIONA [R] PARA RECARGAR"

func _configure_label_style(label: Label, stylebox: StyleBoxFlat, color: Color, font_size: int, is_center: bool = false):
	label.add_theme_stylebox_override("normal", stylebox)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	
	var shadow_offset = 2 if font_size > FONT_SIZE else 1
	label.add_theme_constant_override("shadow_offset_x", shadow_offset)
	label.add_theme_constant_override("shadow_offset_y", shadow_offset)
	
	if is_center:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func update_ui(life: int, ammo: int):
	if not is_instance_valid(player):
		return
	
	# Actualizar vida
	var vida_text = "❤ %d/%d" % [life, _get_player_max_life()]
	if vida_label.text != vida_text:
		vida_label.text = vida_text
		animate_label(vida_label)
	
	# Actualizar balas
	var balas_text = "➺ %d/%d" % [ammo, _get_player_max_ammo()]
	if balas_label.text != balas_text:
		balas_label.text = balas_text
		animate_label(balas_label)
	
	# Cambiar color si quedan pocas balas
	var low_ammo_threshold = max(1, _get_player_max_ammo() * 0.2)
	if ammo <= low_ammo_threshold:
		_update_label_color(balas_label, COLOR_ALERTA)
	else:
		_update_label_color(balas_label, COLOR_BALAS)
	
	# Mostrar/ocultar mensaje de recarga
	_toggle_reload_message(ammo <= 0)

func _update_label_color(label: Label, color: Color):
	label.add_theme_color_override("font_color", color)
	var estilo = label.get_theme_stylebox("normal").duplicate()
	estilo.border_color = color
	label.add_theme_stylebox_override("normal", estilo)

func _toggle_reload_message(show: bool):
	if show:
		recargar_label.modulate.a = 0
		recargar_label.visible = true
		create_tween().tween_property(recargar_label, "modulate:a", 1.0, 0.3)
	else:
		var tween = create_tween()
		tween.tween_property(recargar_label, "modulate:a", 0.0, 0.3)
		tween.finished.connect(_hide_reload_label)

func _hide_reload_label():
	recargar_label.visible = false

func animate_label(label: Label):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(label, "modulate", Color(1.5, 1.5, 1.5), 0.1)
	tween.chain()
	tween.tween_property(label, "scale", Vector2(1, 1), 0.2)
	tween.tween_property(label, "modulate", Color.WHITE, 0.2)

func on_player_died():
	# Efectos cuando el jugador muere
	pass

func _input(event):
	if event.is_action_pressed("reload") and recargar_label.visible and is_instance_valid(player):
		if "reload" in player:
			player.reload()
