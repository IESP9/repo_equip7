extends CharacterBody3D

@export var gravity = 9.8  # Gravedad a aplicar

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta  # Aplica la gravedad
	move_and_slide()  # Mueve al zombie teniendo en cuenta la física
