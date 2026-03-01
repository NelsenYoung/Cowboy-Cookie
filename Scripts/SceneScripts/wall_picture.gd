extends Control

@onready var picture = $Picture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(char_data: CharacterData):
	picture.texture = char_data.poses[0]
