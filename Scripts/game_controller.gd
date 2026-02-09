extends Node

# What does this do again?
# It spawns the characters, handles the money, and places
# the attractions in the scene

var money: int = 0
var drink: DrinkData = null
var num_attraction_slots = 4
var attractions: Array[AttractionDisplay] = []

@onready var attractions_container = $"../EntitiesContainer/Attractions"
@onready var characters_container = $"../EntitiesContainer/Characters"

var time_accumulator: float = 0.0
var tick_interval: float = 2.0  # Seconds between ticks

const AttractionDisplayScene = preload("res://Scenes/AttractionDisplay.tscn")
const CharacterDisplayScene = preload("res://Scenes/CharacterDisplay.tscn")
# Define where attractions appear
const SLOT_POSITIONS = [
	Vector2(400, 200),
	Vector2(400, 500),
	Vector2(400, 800),
	Vector2(400, 1100)
]

func _ready():
	drink = load("res://Resources/drinks/first_drink.tres")
	var attraction = load("res://Resources/attractions/dart_board.tres")
	for i in range(num_attraction_slots):
		spawn_attraction(attraction, i)

func spawn_attraction(attraction_data: AttractionData, slot_idx: int):
	var attraction_instance = AttractionDisplayScene.instantiate()
	attraction_instance.setup(attraction_data, SLOT_POSITIONS[slot_idx])
	attractions_container.add_child(attraction_instance)
	attractions.append(attraction_instance)
	
	
func _process(delta):
	time_accumulator += delta
	
	if time_accumulator >= tick_interval:
		time_accumulator -= tick_interval
		game_tick()

func game_tick():
	spawn_chars_loop()

func spawn_chars_loop():
	var possible_chars = {}
	if drink != null and drink.num_uses > 0:
		for attraction in attractions:
			if attraction != null:
				for slot in attraction.slot_nodes:
					if slot.character == null:
						# Create an array of the possible characters to spawn in this slot
						var slot_possible_chars_d = array_to_dict(slot.data.possible_chars)
						possible_chars = drink.possible_chars
						possible_chars = find_intersection(possible_chars, slot_possible_chars_d)
						
						# Pick a random possible char and try to spawn them
						var char = choose_rand_from_array(possible_chars)
						var spawn_threshold = randf()
						if spawn_threshold < char.hit_rate:
							print(char.char_name + " was spawned at " + slot.get_parent().get_name())
							slot.spawn_char(char)
					else:
						var remove_threshold = randf()
						if remove_threshold < slot.data.character.leave_rate:
							print(slot.data.character.char_name + " left from " + slot.get_parent().get_name())
							slot.remove_char()

func find_intersection(array: Array, set: Dictionary) -> Array:
	var res = []
	for item in array:
		if item in set:
			res.append(item)
	return res

func choose_rand_from_array(possible_chars: Array):
	var idx = randi_range(0, len(possible_chars) - 1)
	return possible_chars[idx]

func array_to_dict(in_array: Array) -> Dictionary:
	var res = {}
	for item in in_array:
		res[item] = true
	return res
