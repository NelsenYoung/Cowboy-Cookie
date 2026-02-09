# character_display.gd
extends Node2D
class_name CharacterDisplay

@onready var sprite: Sprite2D = $Sprite2D
var texture: Texture2D
var data: CharacterData

func setup(character_data: CharacterData):
	data = character_data
	texture = character_data.poses[0]

func _ready():
	sprite.texture = texture
