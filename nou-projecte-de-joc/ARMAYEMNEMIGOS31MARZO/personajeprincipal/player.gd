extends CharacterBody3D

# Referencias a los nodos de la escena
var animation_player : AnimationPlayer
var sketchfab_scene : PackedScene
var weapon : Node3D

# Entrada de movimiento
var speed = 5
var jump_force = 10
var is_running = false
var is_firing = false
var is_reloading = false

# Variables para el control de la cámara
var camera : Camera3D
var mouse_sensitivity : float = 0.1  # Sensibilidad del ratón
var max_look_angle : float = 80  # Ángulo máximo para mirar hacia arriba o abajo
var rotation_x : float = 0.0
var rotation_y : float = 0.0

# Variables del jugador
var current_life = 100
var max_life = 100
var current_ammo = 10
var max_ammo = 10

# Referencia al CanvasLayer (UI)
var canvas_layer : CanvasLayer

@export var bullet_scene: PackedScene  # Arrastra la escena `Bullet.tscn` aquí
@export var fire_rate: float = 0.2  # Tiempo entre disparos

var can_shoot = true

# Inicialización
func _ready():
	# Agregar al jugador al grupo "player"
	add_to_group("player")  

	# Cargar la escena del arma
	sketchfab_scene = preload("res://armas/animated_fps_pistol.glb")
	var weapon_instance = sketchfab_scene.instantiate()
	add_child(weapon_instance)

	# Obtener el AnimationPlayer del arma
	animation_player = weapon_instance.get_node("AnimationPlayer")
	animation_player.play("Pistol_IDLE")

	# Configuración de la cámara
	camera = $CollisionShape3D/Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Obtener la referencia al CanvasLayer para actualizar la UI
	canvas_layer = get_node("/root/Node3D/CanvasLayer")  
	canvas_layer.update_ui()  

# Movimiento de la cámara y rotación
func _input(event):
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -max_look_angle, max_look_angle)
		rotation_y -= event.relative.x * mouse_sensitivity  
		self.rotation.y = deg_to_rad(rotation_y)
		camera.rotation.x = deg_to_rad(rotation_x)

# Movimiento y animaciones del personaje
func _physics_process(_delta: float):  
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

# Función de disparo con reducción de balas
func shoot():
	if can_shoot and current_ammo > 0:
		can_shoot = false

		# Instanciar la bala
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)

		# Obtener la dirección de disparo: hacia donde la cámara está mirando
		var direction = -camera.global_transform.basis.z  # Usar la rotación de la cámara

		# Asegurarse de que la dirección esté normalizada
		direction = direction.normalized()

		# Posicionar la bala ligeramente adelante de la cámara
		bullet.global_transform.origin = camera.global_transform.origin + direction * 2  # Ajustar 2 metros frente a la cámara

		# Aquí ya no usamos `bullet.speed`. En su lugar, aplicamos directamente la velocidad.
		# Asegúrate de que la bala esté utilizando un RigidBody3D
		var speed = 50.0  # Puedes ajustar la velocidad aquí si lo necesitas
		bullet.linear_velocity = direction * speed  # Aplicamos la velocidad directamente a la propiedad linear_velocity

		# Reducir la munición
		current_ammo -= 1
		canvas_layer.update_ui()  # Actualizar la UI para reflejar el nuevo número de balas

		# Temporizador para el próximo disparo
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

# Función de recarga
func reload():
	if current_ammo < max_ammo and animation_player.current_animation != "Pistol_RELOAD" and not is_firing:
		animation_player.play("Pistol_RELOAD")
		is_reloading = true
		animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

# Función que se llama cuando termina una animación
func _on_animation_finished(anim_name: String):
	if anim_name == "Pistol_FIRE":
		is_firing = false
	elif anim_name == "Pistol_RELOAD":
		is_reloading = false
		current_ammo = max_ammo  # Recargar las balas
		canvas_layer.update_ui()  # Actualizar la UI después de recargar
	animation_player.disconnect("animation_finished", Callable(self, "_on_animation_finished"))

# Función para recibir daño
func take_damage(damage: int):
	current_life -= damage
	current_life = clamp(current_life, 0, max_life)  
	print("🔥 Jugador ha recibido", damage, "de daño!")
	
	if current_life <= 0:
		die()

# Función para la muerte del jugador
func die():
	animation_player.play("Pistol_DEATH")
	set_process(false)  
	$CollisionShape3D.disabled = true  
	print("El jugador ha muerto.")

# Obtener estadísticas del jugador (vida y munición)
func get_player_stats():
	return {"life": current_life, "ammo": current_ammo}
