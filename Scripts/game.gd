extends Node2D

@onready var background = $Background
@onready var attraction_menu: Control = $CanvasLayer/Control
signal change_slot_texture(sprite: Texture2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background.slot_clicked.connect(show_menu)
	change_slot_texture.connect(background._change_tex)
	attraction_menu.attraction_chosen.connect(place_attraction)
	attraction_menu.hide()

func show_menu():
	attraction_menu.visible = true

func place_attraction(texture: Texture2D):
	print("Root: ", texture)
	change_slot_texture.emit(texture)
	attraction_menu.visible = false
