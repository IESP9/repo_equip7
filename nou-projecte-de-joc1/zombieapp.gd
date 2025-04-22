extends CharacterBody3D

@export var gravity = 9.8  # Gravedad a aplicar
@export var speed = 3.0  # Velocidad de movimiento del zombie
@export var change_direction_time = 2.0  # Tiempo en segundos para cambiar de dirección

var current_direction: Vector3 = Vector3.ZERO  # Dirección actual del movimiento
var timer: float = 0.0  # Temporizador para cambiar de dirección

func _ready():
	# Iniciar con una dirección aleatoria
	change_direction()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  # Aplica la gravedad

	# Actualizar el temporizador
	timer -= delta
	if timer <= 0:
		change_direction()  # Cambiar de dirección cuando el temporizador llegue a cero

	# Mover al zombie en la dirección actual
	velocity.x = current_direction.x * speed
	velocity.z = current_direction.z * speed

	move_and_slide()  # Mueve al zombie teniendo en cuenta la física

# Función para cambiar la dirección del movimiento
func change_direction():
	# Generar una dirección aleatoria en el plano XZ (horizontal)
	current_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	timer = change_direction_time  # Reiniciar el temporizador
	print("Nueva dirección: ", current_direction)  # Mensaje de depuración
