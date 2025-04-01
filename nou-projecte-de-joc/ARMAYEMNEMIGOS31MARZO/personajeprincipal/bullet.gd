extends RigidBody3D

@export var speed: float = 50.0
@export var damage: int = 10

var direction: Vector3 = Vector3.ZERO

func _ready():
	add_to_group("bullet")
	# Conectar la señal correctamente
	connect("body_entered", _on_body_entered)
	
	# Destruir la bala después de 3 segundos
	get_tree().create_timer(3).timeout.connect(queue_free)

func set_direction(dir: Vector3):
	direction = dir.normalized()

func _physics_process(delta):
	if direction != Vector3.ZERO:
		linear_velocity = direction * speed

func _on_body_entered(body: Node):
	# Asegurarnos de que no procesamos una bala ya eliminada
	if not is_inside_tree():
		return

	print("💥 Colisión con:", body.name)
	
	# Manejar daño con un pequeño retraso para evitar problemas
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		call_deferred("_deal_damage", body, damage)
	elif body.is_in_group("player") and body.has_method("take_damage"):
		call_deferred("_deal_damage", body, damage)
	
	# Destruir la bala en el siguiente frame
	call_deferred("queue_free")

func _deal_damage(target: Node, dmg: int):
	if target.has_method("take_damage"):
		target.take_damage(dmg)
