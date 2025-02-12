extends CharacterBody3D

const SPEED = 15.0
const JUMP_VELOCITY = 30.5
const MOUSE_SENSITIVITY = 0.35

# Variables para manejar la rotación
var yaw := 0.0 # Rotación horizontal (alrededor del eje Y)
var pitch := 0.0 # Rotación vertical (alrededor del eje X)

func _ready() -> void:
	# Captura el ratón para que no salga de la ventana
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Ajusta la rotación según el movimiento del ratón
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY

		# Limita el ángulo vertical (pitch) para evitar que la cámara gire completamente
		pitch = clamp(pitch, -90, 90)

		# Aplica la rotación al nodo
		rotation_degrees.y = yaw
		$Head/Camera3D.rotation_degrees.x = pitch

func _physics_process(delta: float) -> void:
	# Añade la gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Maneja el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtén la dirección del input con WASD
	var input_dir := Vector3()
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	# Mueve el personaje en la dirección correcta
	var direction := (transform.basis * input_dir).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
