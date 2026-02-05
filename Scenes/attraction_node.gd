extends Control

signal attraction_selected(sprite: Sprite2D)

@onready var icon = $TextureRect
@onready var name_label = $Label

func set_data(item: AttractionData):
	icon.texture = item.icon
	name_label.text = item.item_name

func _on_button_pressed() -> void:
	var tex = get_child(0).texture
	attraction_selected.emit(tex)
	print("Node: ", tex)
