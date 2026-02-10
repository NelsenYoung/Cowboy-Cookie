extends Control
class_name DrinkCard

var data: DrinkData

@onready var icon = $IconContainer/Icon
@onready var name_label = $Name
@onready var cost_label = $CostContainer/Cost

func setup(drink_data: DrinkData):
	data = drink_data

func _ready():
	icon.texture = data.texture
	name_label.text = data.drink_name
	cost_label.text = "$%d" % data.price
