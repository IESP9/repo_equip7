extends Node3D  # O CharacterBody3D si es un personaje

@onready var anim1 = $AnimationPlayer
@onready var anim2 = $AnimationPlayer2

func _ready():
	reproducir_animaciones()

func reproducir_animaciones():
	anim1.play("mixamo_com")  # Reproduce la primera animación
	await anim1.animation_finished  # Espera a que termine
	anim2.play("mixamo_com")  # Reproduce la segunda animación
