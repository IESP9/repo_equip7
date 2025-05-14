extends CharacterBody3D

@export var speed: float = 3.0
@export var damage: int = 10
@export var health: int = 50
@export var gravity: float = 50
@export var attack_range: float = 1.5

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $Area3D

var current_target: CharacterBody3D = null
var wait_for_first_frame: bool = true
var attack_cooldown: bool = false
var is_moving: bool = false

func _ready():
	add_to_group("ally")
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = attack_range
	detection_area.body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	if wait_for_first_frame:
		wait_for_first_frame = false
		return  

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Buscar nuevo objetivo si no hay uno actual
	if not current_target or not is_instance_valid(current_target):
		_find_new_target()
		if not current_target:
			return

	# Movimiento hacia el enemigo
	var target_pos = current_target.global_transform.origin
	var direction = (target_pos - global_transform.origin).normalized()
	direction.y = 0
	
	# Verificar distancia para atacar
	if global_transform.origin.distance_to(target_pos) <= attack_range:
		velocity = Vector3.ZERO
		_attack_target()
	else:
		velocity = direction * speed
		# Rotación hacia el enemigo
		look_at(Vector3(target_pos.x, global_position.y, target_pos.z), Vector3.UP)
		is_moving = true

	move_and_slide()
	
	# Si no se está moviendo pero no está atacando
	if velocity.length() < 0.1 and not attack_cooldown:
		is_moving = false


func _find_new_target():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		velocity = Vector3.ZERO
		return
	
	var closest_enemy = null
	var min_distance = INF
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_transform.origin.distance_to(enemy.global_transform.origin)
			if distance < min_distance:
				min_distance = distance
				closest_enemy = enemy
	
	current_target = closest_enemy
	if current_target:
		nav_agent.target_position = current_target.global_transform.origin

func _attack_target():
	if attack_cooldown or not current_target:
		return
		
	if current_target.has_method("take_damage"):
		current_target.take_damage(damage)
		print("⚔️ Aliado atacando enemigo!")
		
		attack_cooldown = true
		await get_tree().create_timer(1.0).timeout
		attack_cooldown = false

func take_damage(damage_amount: int):
	health -= damage_amount
	print("💥 Aliado golpeado! Vida restante: ", health)
	
	if health <= 0:
		die()

func die():
	print("☠️ Aliado eliminado")
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemy_bullet"):
		if body.has_method("get_damage"):
			take_damage(body.get_damage())
		else: 
			take_damage(10)
	elif body.is_in_group("enemy"):
		take_damage(body.damage if body.has_method("take_damage") else 10)
