extends Resource
class_name AttractionSlotData

@export var id: int
@export var pos: Vector2
@export var path: String = resource_path
@export var possible_chars: Array[CharacterData]
var character: CharacterData = null

func spawn_char(char: CharacterData):
	character = char

func remove_char():
	character = null

func _get_path():
	return resource_path
