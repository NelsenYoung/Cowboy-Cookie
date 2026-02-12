extends Control
class_name GiftCard

var character_data: CharacterData
var amount: int

@onready var label = $HBoxContainer/Label
@onready var char_icon = $HBoxContainer/TextureRect

func setup(character: CharacterData, gift_amount: int) -> void:
	character_data = character
	amount = gift_amount

func _ready():
	label.text ="$%d" % amount
	# This is temporary and must change later. Character data should have something like an icon field
	char_icon.texture = character_data.poses[0]
