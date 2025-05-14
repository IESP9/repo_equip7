extends RigidBody3D

@export var costo: int = 200
@export var mejoras: Array[Dictionary] = [
	{"nombre": "Doble Daño", "tipo": "daño", "valor": 2.0, "duracion": 30.0},
	{"nombre": "Velocidad+", "tipo": "velocidad", "valor": 1.5, "duracion": 20.0},
	{"nombre": "Vida Extra", "tipo": "vida", "valor": 50, "permanente": true},
	{"nombre": "Escudo", "tipo": "escudo", "valor": 100, "duracion": 15.0}
]

@onready var area = $Area3D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and Global.canjear_puntos(costo):
		aplicar_mejora_aleatoria(body)
		$AudioStreamPlayer3D.play()
		hide()  # Oculta la caja antes de liberarla
		await $AudioStreamPlayer3D.finished
		queue_free()

func aplicar_mejora_aleatoria(jugador):
	var mejora = mejoras[randi() % mejoras.size()]
	
	match mejora["tipo"]:
		"daño":
			jugador.aplicar_mejora_daño(mejora["valor"], mejora.get("duracion", 0.0))
		"velocidad":
			jugador.aplicar_mejora_velocidad(mejora["valor"], mejora.get("duracion", 0.0))
		"vida":
			jugador.aplicar_mejora_vida(mejora["valor"])
		"escudo":
			jugador.aplicar_mejora_escudo(mejora["valor"], mejora.get("duracion", 0.0))
	
	Global.mejora_aplicada.emit(mejora["nombre"])
	print("Mejora aplicada: ", mejora["nombre"])
