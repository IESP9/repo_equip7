extends CharacterBody3D

@export var speed: float = 2.0
@export var damage: int = 10
@export var health: int = 30

var player: Node3D
var is_attacking: bool = false
var nav_path: PackedVector3Array

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	$AnimationPlayer.play("walk_loop")

func _physics_process(delta):
	if player and not is_attacking:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		move_and_slide()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	$AnimationPlayer.play("die")
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_attack_area_body_entered(body):
	if body == player:
		is_attacking = true
		$AnimationPlayer.play("attack")
		await $AnimationPlayer.animation_finished
		body.take_damage(damage)
		is_attacking = false

func update_navigation():
	if player:
		var map = get_world_3d().navigation_map
		nav_path = NavigationServer3D.map_get_path(
			map,
			global_position,
			player.global_position,
			true
		)
		if nav_path.size() > 1:
			velocity = (nav_path[1] - global_position).normalized() * speed
