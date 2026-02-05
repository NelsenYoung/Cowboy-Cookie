extends Area2D

signal show_attraction_menu(name: String)

#func _ready():
	#print(name)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		emit_signal("show_attraction_menu", name)
