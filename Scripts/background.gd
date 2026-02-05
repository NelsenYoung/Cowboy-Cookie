extends Node2D

signal slot_clicked()
signal change_texture(tex: Texture2D)
var selected_slot: String = ""

func _ready():
	var nodes = get_child(1).get_children()
	for child in nodes:
		child.show_attraction_menu.connect(show_menu)

func show_menu(name: String) -> void:
	print("Background clicked from ", name)
	selected_slot = name
	slot_clicked.emit()

func _change_tex(texture: Texture2D):
	print("background change texture of grandchild")
	var path := "slots/" + selected_slot
	var child = get_node_or_null(path)
	
	if child:
		child.get_node("Sprite2D").texture = texture
