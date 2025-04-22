extends CharacterBody3D

# Referencias a los nodos de la escena
var animation_player : AnimationPlayer
var sketchfab_scene : PackedScene
var weapon : Node3D

# Entrada de movimiento
var speed = 5
var jump_force = 5
var is_running = false
var is_firing = false
var is_reloading = false

# Variables para el control de la cámara
var camera : Camera3D
var mouse_sensitivity : float = 0.1  
var max_look_angle : float = 80  
var rotation_x : float = 0.0
var rotation_y : float = 0.0

# Variables del jugador
var current_life = 100
var max_life = 100
var current_ammo = 10
var max_ammo = 10

# Referencia al CanvasLayer (UI) propio del jugador
var canvas_layer : CanvasLayer
var Vida : Label
var Balas : Label

@export var bullet_scene: PackedScene = preload("res://bullet.tscn")  # Asignación directa
@export var fire_rate: float = 0.2  

var can_shoot = true

# Inicialización
func _ready():
	add_to_group("player")  

	# Cargar el arma
	sketchfab_scene = preload("res://armas/animated_fps_pistol.glb")
	var weapon_instance = sketchfab_scene.instantiate()
	add_child(weapon_instance)

	# Obtener el AnimationPlayer del arma
	animation_player = weapon_instance.get_node("AnimationPlayer")
	animation_player.play("Pistol_IDLE")

	# Configuración de la cámara
	camera = $CollisionShape3D/Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Configurar el CanvasLayer propio
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

	# Crear etiquetas de vida y balas
	Vida = Label.new()
	Balas = Label.new()
	canvas_layer.add_child(Vida)
	canvas_layer.add_child(Balas)

	# Ajustes de posición y estilo
	Vida.position = Vector2(20, 20)
	Balas.position = Vector2(20, 50)
	Vida.modulate = Color(1, 0, 0)  # Rojo para vida
	Balas.modulate = Color(1, 1, 0)  # Amarillo para balas
	update_ui()

# Función para actualizar la UI
func update_ui():
	Vida.text = "Vida: " + str(current_life) + " / " + str(max_life)
	Balas.text = "Balas: " + str(current_ammo) + " / " + str(max_ammo)

# Movimiento de la cámara y rotación
func _input(event):
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -max_look_angle, max_look_angle)
		rotation_y -= event.relative.x * mouse_sensitivity  
		self.rotation.y = deg_to_rad(rotation_y)
		camera.rotation.x = deg_to_rad(rotation_x)

# Movimiento y animaciones del personaje
func _physics_process(delta: float):  
	var direction = Vector3.ZERO
	is_running = false

	if Input.is_action_pressed("move_forward"):
		direction += transform.basis.z  
		is_running = true
	if Input.is_action_pressed("move_backwards"):
		direction -= transform.basis.z  
		is_running = true
	if Input.is_action_pressed("move_left"):
		direction += transform.basis.x  
		is_running = true
	if Input.is_action_pressed("move_right"):
		direction -= transform.basis.x  
		is_running = true
	
	direction = direction.normalized()

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		animation_player.play("Pistol_JUMP")
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()

	if not is_firing:
		if is_running:
			if animation_player.current_animation != "Pistol_RUN" and not is_reloading:
				animation_player.play("Pistol_RUN")
		elif not is_reloading:
			if animation_player.current_animation != "Pistol_IDLE":
				animation_player.play("Pistol_IDLE")

	if Input.is_action_just_pressed("fire") and not is_reloading:
		shoot()
	
	if Input.is_action_just_pressed("reload"):
		reload()

# Función de disparo CORREGIDA
func shoot():
	if can_shoot and current_ammo > 0:
		can_shoot = false
		is_firing = true
		animation_player.play("Pistol_FIRE")

		# Verificación de bullet_scene
		if bullet_scene == null:
			printerr("ERROR: No se asignó bullet_scene")
			return

		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)

		var direction = -camera.global_transform.basis.z
		direction = direction.normalized()

		bullet.global_transform.origin = camera.global_transform.origin + direction * 2

		var bullet_speed = 50.0
		bullet.linear_velocity = direction * bullet_speed

		current_ammo -= 1
		update_ui()  

		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true
		is_firing = false

# Función de recarga
func reload():
	if current_ammo < max_ammo and animation_player.current_animation != "Pistol_RELOAD" and not is_firing:
		animation_player.play("Pistol_RELOAD")
		is_reloading = true
		await animation_player.animation_finished
		is_reloading = false
		current_ammo = max_ammo
		update_ui()

# Función para recibir daño
func take_damage(damage: int):
	current_life -= damage
	current_life = clamp(current_life, 0, max_life)  
	print("🔥 Jugador ha recibido ", damage, " de daño!")
	update_ui()  

	if current_life <= 0:
		die()

# Función para la muerte del jugador
func die():
	animation_player.play("Pistol_DEATH")
	set_process(false)  
	$CollisionShape3D.disabled = true  
	print("El jugador ha muerto.")

# Obtener estadísticas del jugador
func get_player_stats():
	return {"life": current_life, "ammo": current_ammo}
