extends CharacterBody3D

const SPEED = 6.0
const JUMP_VELOCITY = 5.5
const MOUSE_SENSITIVITY = 0.35
const HEAD_BOB_SPEED = 10.0  # Velocidad del head bobbing
const HEAD_BOB_AMOUNT = 0.1  # Intensidad del movimiento de la cámara

var yaw := 0.0
var pitch := 0.0
var head_bob_timer := 0.0  # Controla el tiempo para la animación

@onready var camera = $Head/Camera3D
@onready var head = $Head  # Nodo de la cabeza (NO modificar su posición global)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("Player")  

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -90, 90)
		rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Manejar el salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento con WASD
	var input_dir := Vector3()
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	# Dirección del movimiento
	var direction := (transform.basis * input_dir).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		_apply_head_bobbing(delta)  # Activar efecto de caminar
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		camera.transform.origin.y = 0  # Resetear la cámara cuando se detiene

	move_and_slide()

func _apply_head_bobbing(delta: float) -> void:
	if is_on_floor():
		head_bob_timer += delta * HEAD_BOB_SPEED
		camera.transform.origin.y = sin(head_bob_timer) * HEAD_BOB_AMOUNT
