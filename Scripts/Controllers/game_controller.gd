extends Node

var money: int = 0
var drink: DrinkData = null
var num_attraction_slots = 3
var attractions: Array[AttractionDisplay] = []
var characters: Dictionary[CharacterData, bool] = {}
var unclaimed_gifts: Dictionary = {}
var unique_gift_id: int = 0

@onready var attractions_container = $"../EntitiesContainer/Attractions"
@onready var characters_container = $"../EntitiesContainer/Characters"
@onready var drinks_container = $"../EntitiesContainer/Drinks"
@onready var attraction_slots_container = $"../UIController/AttractionSlotButtons"
@onready var ui_controller = $"../UIController"

@onready var money_label = $"../UIController/MoneyDisplay/MoneyLabel"

var time_accumulator: float = 0.0
var tick_interval: float = 2.0  # Seconds between ticks

const AttractionDisplayScene = preload("res://Scenes/AttractionDisplay.tscn")
const CharacterDisplayScene = preload("res://Scenes/CharacterDisplay.tscn")
const DrinkDisplayScene = preload("res://Scenes/DrinkDisplay.tscn")

var TEST_ATTRACTIONS = [load("res://Resources/attractions/piano.tres"), load("res://Resources/attractions/poker_table.tres"), load("res://Resources/attractions/table.tres")]
var TEST_DRINK = load("res://Resources/drinks/first_drink.tres")

const DEBUG_MODE = true
const DEBUG_ONE_HOUR_PASSED = 3600
const DEBUG_SIX_HOURS_PASSED = 10800
const DEBUG_TEN_HOURS_PASSED = 36000

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
	_on_drink_selected(TEST_DRINK)
	
	var slot_buttons = attraction_slots_container.get_children()
	for i in range(num_attraction_slots):
		attractions.append(null)
		
	for i in range(num_attraction_slots):
		_on_attraction_selected(i, TEST_ATTRACTIONS[i])
		
	ui_controller.attraction_card_selected.connect(_on_attraction_selected)
	ui_controller.drink_card_selected.connect(_on_drink_selected)
	ui_controller.gift_claimed.connect(_on_gift_claimed)
	
	await get_tree().create_timer(0.5).timeout  # Wait 2 seconds
	#print("This prints after 2 seconds")
	
	if DEBUG_MODE:
		var current_time = Time.get_unix_time_from_system()
		var fake_last_login = current_time - DEBUG_ONE_HOUR_PASSED
		
		if drink == null:
			# Clear all characters from the screen
			pass
		
		for attraction in attractions:
			if attraction != null:
				for slot in attraction.slot_nodes:
					simulate_slot(slot, current_time, fake_last_login)

#func _process(delta):
	#time_accumulator += delta
	#
	#if time_accumulator >= tick_interval:
		#time_accumulator -= tick_interval
		#game_tick()

func game_tick():
	spawn_chars_loop()

func simulate_slot(slot: AttractionSlotNode, current_time:float, last_login_time: float):
	print(Time.get_datetime_string_from_unix_time(current_time))
	print(Time.get_datetime_string_from_unix_time(last_login_time))
	var tick = 60
	var sim_time = last_login_time
	while sim_time < current_time:
		#print("Sim Time:", Time.get_datetime_string_from_unix_time(sim_time))
		if slot.character != null:
			if slot.character.departure_time <= sim_time:
				slot.remove_char()
			sim_time += tick
		else:
			# Get possible char
			var char = try_to_spwan(slot, sim_time)
			if char != null:
				if slot.character.departure_time > current_time:
					print(slot.character.data.char_name + " Spawned and won't leave until " + Time.get_datetime_string_from_unix_time(slot.character.departure_time))
				else:
					print(slot.character.data.char_name + " Came and left at" + Time.get_datetime_string_from_unix_time(slot.character.departure_time))
					sim_time = slot.character.departure_time
					remove_char(slot, char, true)
			else:
				sim_time += tick

func try_to_spwan(slot: AttractionSlotNode, time: float) -> CharacterData:
	var possible_chars = {}
	
	# Create an array of the possible characters to spawn in this slot
	var slot_possible_chars_d = array_to_dict(slot.data.possible_chars)
	possible_chars = drink.possible_chars
	possible_chars = find_intersection(possible_chars, slot_possible_chars_d)
	
	# Ensure that we don't spawn a character already in the scene
	for char in characters:
		possible_chars.erase(char)
	
	if len(possible_chars) == 0:
		return null
	
	# Pick a random possible char and try to spawn them
	var char = choose_rand_from_array(possible_chars)
	var spawn_threshold = randf()
	if spawn_threshold < char.hit_rate:
		spawn_char(slot, char, time)
		return char
	return null

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
						for char in characters:
							possible_chars.erase(char)
						
						if len(possible_chars) == 0:
							continue
						
						# Pick a random possible char and try to spawn them
						var char = choose_rand_from_array(possible_chars)
						var spawn_threshold = randf()
						if spawn_threshold < char.hit_rate:
							pass
							#spawn_char(slot, char)
					else:
						var remove_threshold = randf()
						if remove_threshold < slot.data.character.leave_rate:
							remove_char(slot, slot.data.character, false)

func spawn_char(slot: AttractionSlotNode, char: CharacterData, time: float):
	print(char.char_name + " was spawned at " + slot.get_parent().get_name())
	characters[char] = true
	slot.spawn_char(char, time)

func remove_char(slot: AttractionSlotNode, char: CharacterData, sim: bool):
	# print(slot.data.character.char_name + " left from " + slot.get_parent().get_name())
	var amount: int = floor(10 * char.money_rate * randf())
	unclaimed_gifts[unique_gift_id] = [char, amount]
	unique_gift_id += 1
	characters.erase(char)
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

func _on_attraction_selected(slot_idx: int, attraction: AttractionData):
	var attraction_instance = AttractionDisplayScene.instantiate()
	attraction_instance.setup(attraction, attraction_slots_container.get_child(slot_idx).position)
	attractions_container.add_child(attraction_instance)
	if attractions[slot_idx] != null:
		attractions[slot_idx].queue_free()
	attractions[slot_idx] = attraction_instance

func _on_drink_selected(drink_data: DrinkData):
	var drink_instance = DrinkDisplayScene.instantiate()
	drink_instance.setup(drink_data)
	drinks_container.add_child(drink_instance)
	drink = drink_data

func _on_gift_claimed(id: int, amount: int):
	money += amount
	unclaimed_gifts.erase(id)
	ui_controller.update_money_label(money)
