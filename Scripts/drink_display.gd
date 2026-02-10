extends Node2D
class_name DrinkDisplay

@onready var sprite: Sprite2D = $Sprite2D

var data: DrinkData

func setup(drink_data: DrinkData):
	data = drink_data

func _ready():
	sprite.texture = data.texture
