extends Node2D
class_name AttractionSlotNode

var data: AttractionSlotData
var character: CharacterDisplay = null

@onready var root = $"."
const CharacterScene = preload("res://Scenes/CharacterDisplay.tscn")

func setup(slot_data: AttractionSlotData):
	data = slot_data
	data.character = null

func spawn_char(char: CharacterData):
	var char_instance = CharacterScene.instantiate()
	char_instance.setup(char)
	root.add_child(char_instance)
	character = char_instance
	data.character = char

func remove_char():
	if character != null:
		character.queue_free()
		character = null
		data.character = null
