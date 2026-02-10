extends Node

var money: int = 0
var drink: DrinkData = null
var num_attraction_slots = 4
var attractions: Array[AttractionDisplay] = []

@onready var attractions_container = $"../EntitiesContainer/Attractions"
@onready var characters_container = $"../EntitiesContainer/Characters"
@onready var drinks_container = $"../EntitiesContainer/Drinks"
@onready var attraction_slots_container = $"../UIController/AttractionSlotButtons"
@onready var ui_controller = $"../UIController"

var time_accumulator: float = 0.0
var tick_interval: float = 2.0  # Seconds between ticks

const AttractionDisplayScene = preload("res://Scenes/AttractionDisplay.tscn")
const CharacterDisplayScene = preload("res://Scenes/CharacterDisplay.tscn")
const DrinkDisplayScene = preload("res://Scenes/DrinkDisplay.tscn")

# Define where attractions appear
const SLOT_POSITIONS = [
	Vector2(400, 200),
	Vector2(400, 500),
	Vector2(400, 800),
	Vector2(400, 1100)
]

const DRINK_SLOT_POSITION = Vector2(200, 640)

func _ready():
	var drink_slot_button = $"../UIController/DrinkSlotButton/SlotButton1"
	drink_slot_button.position = DRINK_SLOT_POSITION
	drinks_container.position = DRINK_SLOT_POSITION
	
	var slot_buttons = attraction_slots_container.get_children()
	for i in range(num_attraction_slots):
		slot_buttons[i].position = SLOT_POSITIONS[i]
		attractions.append(null)
		
	ui_controller.attraction_card_selected.connect(_on_attraction_selected)
	ui_controller.drink_card_selected.connect(_on_drink_selected)

func _on_attraction_selected(slot_idx: int, attraction: AttractionData):
	var attraction_instance = AttractionDisplayScene.instantiate()
	attraction_instance.setup(attraction, SLOT_POSITIONS[slot_idx])
	attractions_container.add_child(attraction_instance)
	attractions[slot_idx] = attraction_instance

func _on_drink_selected(drink_data: DrinkData):
	print("Drink Selected")
	var drink_instance = DrinkDisplayScene.instantiate()
	drink_instance.setup(drink_data)
	drinks_container.add_child(drink_instance)
	drink = drink_data

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
