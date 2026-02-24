extends Control
class_name AttractionCard

var data: AttractionData

@onready var icon = $IconContainer/Icon
@onready var name_label = $Name
@onready var cost_label = $CostContainer/Cost

func setup(attraction_data: AttractionData):
	data = attraction_data

func _ready():
	icon.texture = data.texture
	name_label.text = data.attraction_name
	cost_label.text = "$%d" % data.price
