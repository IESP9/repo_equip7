extends Area3D

@export var target_scene: String = "res://primermapa.tscn"

func _on_body_entered(body):
	if body is CharacterBody3D:
		var loading_ui = get_tree().get_first_node_in_group("loading_ui")
		
		if loading_ui:
			loading_ui.show_loading()  # Muestra la pantalla de carga
			
			await get_tree().process_frame  # Espera un frame para dibujar la pantalla de carga
			await get_tree().create_timer(1.5).timeout  # Simula un tiempo de carga

		get_tree().call_deferred("change_scene_to_file", target_scene)  # Ahora cambia de escena
