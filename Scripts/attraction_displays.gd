# attraction_display.gd
extends Node2D
class_name AttractionDisplay

@onready var sprite = $Sprite2D
@onready var root = $"."

var texture: Texture2D
var data: AttractionData
var slots: Array[AttractionSlotData]
var slot_nodes: Array[AttractionSlotNode]
const AttractionSlotNode = preload("res://Scenes/AttractionSlotNode.tscn")

func setup(attraction_data: AttractionData, slot_position: Vector2):
	texture = attraction_data.texture
	position = slot_position
	data = attraction_data

func create_slots():
	for slot in data.slots:
		var slot_instance = AttractionSlotNode.instantiate()
		slot_instance.setup(slot.duplicate())
		root.add_child(slot_instance)
		slot_nodes.append(slot_instance)

func _ready():
	sprite.texture = texture
	create_slots()
