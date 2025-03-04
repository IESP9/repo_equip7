extends CharacterBody3D

@export var gravity = 9.8  # Gravedad a aplicar
@export var speed = 3.0  # Velocidad de movimiento del zombie

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  # Aplica la gravedad

	# Si el jugador existe, mover al zombie hacia él
	if Global.player:
		# Recalcula la dirección hacia el jugador en cada frame
		var direction = (Global.player.global_transform.origin - global_transform.origin).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		print("Posición del jugador: ", Global.player.global_transform.origin)  # Mensaje de depuración
		print("Posición del zombie: ", global_transform.origin)  # Mensaje de depuración
	else:
		print("Error: No se encontró al jugador.")  # Mensaje de depuración

	move_and_slide()  # Mueve al zombie teniendo en cuenta la física
