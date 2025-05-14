extends CharacterBody3D

signal boss_derrotado

@export var speed: float = 5.0
@export var damage: int = 50
@export var health: int = 200
@export var gravity: float = 50

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $Zombie/AnimationPlayer

var player: CharacterBody3D = null
var wait_for_first_frame: bool = true

func _ready():
	add_to_group("enemy")
	
	# Buscar al jugador
	for node in get_tree().get_nodes_in_group("player"):
		player = node
		break  

	if player == null:
		print("⚠️ No se encontró al jugador en la escena.")

	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0

	detection_area.body_entered.connect(_on_body_entered)
	
	# Configurar animación
	_setup_zombie_animation()

func _setup_zombie_animation():
	if not animation_player:
		return
		
	var anim_list = animation_player.get_animation_list()
	if anim_list.size() == 0:
		return
		
	var anim_name = anim_list[0]
	
	# Solución para Godot 4 - Bucle manual
	animation_player.play(anim_name)
	animation_player.animation_finished.connect(_on_animation_finished.bind(anim_name))

func _on_animation_finished(anim_name: String):
	# Reiniciar la animación para simular bucle
	animation_player.play(anim_name)

func _physics_process(delta):
	if wait_for_first_frame:
		wait_for_first_frame = false
		return  

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Movimiento hacia el jugador
	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		direction.y = 0
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# Rotación hacia el jugador
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

	move_and_slide()

func take_damage(damage_amount: int):
	health -= damage_amount
	print("💥 Boss golpeado! Vida restante: ", health)
	
	if health <= 0:
		die()

func die():
	print("☠️ Boss eliminado")
	emit_signal("boss_derrotado")
	Global.agregar_puntos(100)
	queue_free()

func _on_body_entered(body):
	# Detección de balas
	if body.is_in_group("bullet"):
		if body.has_method("get_damage"):
			var damage_received = body.get_damage()
			take_damage(damage_received)
		else: 
			print("⚠️ Bala sin daño definido. Usando daño por defecto: 10")
			take_damage(10)
	# Detección del jugador
	elif body.is_in_group("player"):
		print("👊 Boss atacando al jugador")
		if body.has_method("take_damage"):
			body.take_damage(damage)
