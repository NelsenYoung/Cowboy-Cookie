# character_display.gd
extends Node2D
class_name CharacterDisplay

@onready var sprite: Sprite2D = $Sprite2D
var texture: Texture2D
var data: CharacterData

var arrival_time = Time.get_unix_time_from_system()
var stay_duration = randi_range(1800, 2700)  # 30-45 mins in seconds+
var departure_time = arrival_time + stay_duration

func setup(character_data: CharacterData):
	data = character_data
	texture = character_data.poses[0]

func _ready():
	sprite.texture = texture
