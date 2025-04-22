extends CharacterBody3D

@export var speed: float = 3.0
@export var damage: int = 10
@export var health: int = 50  # Vida del enemigo

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $Area3D

var player: CharacterBody3D = null
var wait_for_first_frame: bool = true

func _ready():
	add_to_group("enemy")  # Asegurarse que el enemigo está en el grupo
	
	# Buscar al jugador
	for node in get_tree().get_nodes_in_group("player"):
		player = node
		break  

	if player == null:
		print("⚠️ No se encontró al jugador en la escena.")

	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0

	# Conectar señales de detección
	detection_area.body_entered.connect(_on_body_entered)

func _physics_process(_delta):
	if wait_for_first_frame:
		wait_for_first_frame = false
		return  

	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		velocity = direction * speed

	move_and_slide()

func take_damage(damage_amount: int):
	health -= damage_amount
	print("💥 Enemigo golpeado! Vida restante: ", health)
	
	if health <= 0:
		die()

func die():
	print("☠️ Enemigo eliminado")
	queue_free()  # Esto elimina al enemigo de la escena

func _on_body_entered(body):
	# Detección de balas (RigidBody3D)
	if body.is_in_group("bullet"):
		if body.has_method("get_damage"):  # Verificamos si la bala tiene método de daño
			var damage_received = body.get_damage()
			take_damage(damage_received)
		else: 
			print("⚠️ Bala sin daño definido. Usando daño por defecto: 10")
			take_damage(10)  # Daño por defecto
	
	# Detección del jugador
	elif body.is_in_group("player"):
		print("👊 Enemigo atacando al jugador")
		if body.has_method("take_damage"):
			body.take_damage(damage)
