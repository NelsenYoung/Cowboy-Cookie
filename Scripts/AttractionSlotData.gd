extends Resource
class_name AttractionSlotData

@export var pos: Vector2
@export var texture: Texture2D = load("res://Assests/tile_0104.png")
@export var possible_chars: Array[CharacterData]
var character: CharacterData = null

func spawn_char(char: CharacterData):
	character = char

func remove_char():
	character = null
