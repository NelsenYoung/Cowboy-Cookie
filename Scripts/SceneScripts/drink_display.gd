extends Node2D
class_name DrinkDisplay

@onready var sprite: Sprite2D = $Sprite2D

var data: DrinkData
var time_placed: float

func setup(drink_data: DrinkData, time: float):
	data = drink_data
	time_placed = time
	
func _ready():
	sprite.texture = data.texture
