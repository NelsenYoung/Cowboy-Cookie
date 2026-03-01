extends Node

var money: int = 500
var drink: DrinkDisplay = null
var num_attraction_slots = 3
var attractions: Array[AttractionDisplay] = []
var characters: Dictionary[CharacterData, bool] = {}
var unclaimed_gifts: Dictionary = {}
var unique_gift_id: int = 0
var last_login_time:float = 0
var purchased_attractions: Dictionary = {}
var all_visited_chars: Dictionary = {}

@onready var attractions_container = $"../EntitiesContainer/Attractions"
@onready var characters_container = $"../EntitiesContainer/Characters"
@onready var drinks_container = $"../EntitiesContainer/Drinks"
@onready var attraction_slots_container = $"../UIController/AttractionSlotButtons"
@onready var ui_controller = $"../UIController"
@onready var money_label = $"../UIController/MoneyDisplay/MoneyLabel"
@onready var wall_pictures_container = $"../UIController/WallPictures/MarginContainer/GridContainer"

const AttractionDisplayScene = preload("res://Scenes/AttractionDisplay.tscn")
const CharacterDisplayScene = preload("res://Scenes/CharacterDisplay.tscn")
const DrinkDisplayScene = preload("res://Scenes/DrinkDisplay.tscn")
const PictureFrameScene = preload("res://Scenes/wall_picture.tscn")

var TEST_ATTRACTIONS = [load("res://Resources/attractions/piano.tres"), load("res://Resources/attractions/poker_table.tres"), load("res://Resources/attractions/table.tres")]
var TEST_DRINK = load("res://Resources/drinks/first_drink.tres")

const DEBUG_MODE = false
const DEBUG_ONE_HOUR_PASSED = 3600
const DEBUG_SIX_HOURS_PASSED = 10800
const DEBUG_TEN_HOURS_PASSED = 36000

const RESTART = false
const FIRST_LOGIN = false

# Define where attractions appear
const SLOT_POSITIONS = [
	Vector2(400, 200),
	Vector2(400, 500),
	Vector2(400, 800),
	Vector2(400, 1100)
]

const DRINK_SLOT_POSITION = Vector2(200, 640)

func _ready():
	#var drink_slot_button = $"../UIController/DrinkSlotButton/SlotButton1"
	#_on_drink_selected(TEST_DRINK)
	
	var slot_buttons = attraction_slots_container.get_children()
	for i in range(num_attraction_slots):
		attractions.append(null)
		
	#for i in range(num_attraction_slots):
		#_on_attraction_selected(i, TEST_ATTRACTIONS[i])
		
	ui_controller.attraction_card_selected.connect(_on_attraction_selected)
	ui_controller.attraction_purchase_requested.connect(_on_attraction_purchased)
	ui_controller.drink_card_selected.connect(_on_drink_selected)
	ui_controller.gift_claimed.connect(_on_gift_claimed)
	
	await get_tree().create_timer(0.5).timeout  # Wait 0.5 seconds
	var current_time = Time.get_unix_time_from_system()
	
	if DEBUG_MODE:
		if not RESTART:
			var save_data = load_game()
			read_save_data(save_data)
		last_login_time = current_time - DEBUG_ONE_HOUR_PASSED
	
	var save_data = load_game()
	if save_data != null:
		read_save_data(save_data)

	if FIRST_LOGIN:
		# run the tutorial and init
		pass
	
	if drink == null:
		print("removing all chars because there is no drink")
		remove_all_chars()
	else:
		# Calculate time passed since drink was placed
		var drink_ttl = (drink.time_placed + drink.data.time) - current_time
		print("Drink Time to Live: ", drink_ttl)
		if drink_ttl > (drink.data.time / 2):
			drink.change_state(0)
		elif drink_ttl < (drink.data.time / 2) and drink_ttl > 0:
			drink.change_state(1)
		else:
			drink.change_state(2)
			print("removing all chars because the drink is empty")
			remove_all_chars()

	for attraction in attractions:
		if attraction != null:
			for slot in attraction.slot_nodes:
				simulate_slot(slot, current_time, last_login_time)
	create_picture_wall_frames()

func simulate_slot(slot: AttractionSlotNode, current_time:float, last_login_time: float):
	var tick = 5
	var sim_time = last_login_time
	while sim_time < min(current_time, drink.time_placed + drink.data.time):
		#print("Sim Time:", Time.get_datetime_string_from_unix_time(sim_time))
		if slot.character != null:
			if slot.character.departure_time <= sim_time:
				slot.remove_char()
			sim_time += tick
		else:
			if (drink.time_placed + drink.data.time) - sim_time > 0:
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
			else:
				sim_time += tick

func try_to_spwan(slot: AttractionSlotNode, time: float) -> CharacterData:
	var possible_chars = {}
	
	# Create an array of the possible characters to spawn in this slot
	var slot_possible_chars_d = array_to_dict(slot.data.possible_chars)
	possible_chars = drink.data.possible_chars
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

func spawn_char(slot: AttractionSlotNode, char: CharacterData, time: float):
	characters[char] = true
	all_visited_chars[char] = true
	slot.spawn_char(char, time, drink.time_placed + drink.data.time)

func remove_char(slot: AttractionSlotNode, char: CharacterData, sim: bool):
	# print(slot.data.character.char_name + " left from " + slot.get_parent().get_name())
	leave_gift(char)
	characters.erase(char)
	slot.remove_char()

func remove_all_chars() -> void:
	for attraction in attractions:
		if attraction != null:
			for slot in attraction.slot_nodes:
				if slot.character != null:
					remove_char(slot, slot.data.character, false)

func create_picture_wall_frames():
	for character in all_visited_chars:
		var picture = PictureFrameScene.instantiate()
		wall_pictures_container.add_child(picture)
		picture.setup(character)

func leave_gift(char: CharacterData) -> int:
	var amount: int = floor(10 * char.money_rate * randf())
	unclaimed_gifts[unique_gift_id] = [char, amount]
	unique_gift_id += 1
	return amount
	
func find_intersection(array: Array, set: Dictionary) -> Array:
	var res = []
	for item in array:
		if item.char_name in set:
			res.append(item)
	return res

func choose_rand_from_array(possible_chars: Array):
	var idx = randi_range(0, len(possible_chars) - 1)
	return possible_chars[idx]

func array_to_dict(in_array: Array) -> Dictionary:
	var res = {}
	for item in in_array:
		res[item.char_name] = true
	return res

# ------------------- UI Interactions ------------------- #

func _on_attraction_selected(slot_idx: int, attraction: AttractionData):
	var attraction_instance = AttractionDisplayScene.instantiate()
	attraction_instance.setup(attraction, attraction_slots_container.get_child(slot_idx).position)
	attractions_container.add_child(attraction_instance)
	if attractions[slot_idx] != null:
		attractions[slot_idx].queue_free()
	attractions[slot_idx] = attraction_instance

func _on_attraction_purchased(slot_idx: int, attraction: AttractionData) -> void:
	money -= attraction.price
	purchased_attractions[attraction] = true
	_on_attraction_selected(slot_idx, attraction)
	ui_controller.update_money_label(money)
	return

func _on_drink_selected(drink_data: DrinkData, time_placed: float = Time.get_unix_time_from_system()):
	var drink_instance = DrinkDisplayScene.instantiate()
	drink_instance.setup(drink_data, time_placed)
	drinks_container.add_child(drink_instance)
	drink = drink_instance
	money -= drink_data.price
	ui_controller.update_money_label(money)

func _on_gift_claimed(id: int, amount: int):
	money += amount
	unclaimed_gifts.erase(id)
	ui_controller.update_money_label(money)

# ------------------- SAVE GAME LOGIC ------------------- #

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		print("Trying to save game")
		save_game()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Trying to save game")
		save_game()

func save_game():
	var save_data = {
		"last_login_time": Time.get_unix_time_from_system(),
		"money": money,
		"drink": drink.data.resource_path if drink else null,
		"drink_time_placed": drink.time_placed if drink else null,
		"attractions": serialize_attractions(),
		"characters": serialize_characters(),
		"unclaimed_gifts": serialize_gifts(),
		"purchased_attractions": serialize_purchased_attractions(),
		"all_visited_chars": serialize_all_visited_chars()
	}

	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_var(save_data)
	file.close()
	
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return null
	
	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var save_data = file.get_var()
	file.close()
	
	return save_data

func read_save_data(save_data: Dictionary):
	last_login_time = save_data["last_login_time"]
	money = save_data["money"]
	
	# place the existing drink if it exists
	if save_data["drink"] != null:
		_on_drink_selected(load(save_data["drink"]), save_data["drink_time_placed"])

	# place the existing attractions if they exist
	for i in range(num_attraction_slots):
		if save_data["attractions"][i] != null:
			_on_attraction_selected(i, load(save_data["attractions"][i]))
	
	# place the characters if there are any
	for character_data in save_data["characters"]:
		if character_data != null:
			var cur_attraction = attractions_container.get_child(character_data["attraction_index"])
			var cur_slot = cur_attraction.get_child(character_data["slot_index"])
			spawn_char(cur_slot, load(character_data["char"]), character_data["arrival"])
	
	# Store Unclaimed gifts if there are any
	for gift in save_data["unclaimed_gifts"]:
		leave_gift(load(gift["char"]))
	
	if "purchased_attractions" in save_data:
		for purchased_attraction in save_data["purchased_attractions"]:
			purchased_attractions[load(purchased_attraction["attraction"])] = true
	
	if "all_visited_chars" in save_data:
		for character in save_data["all_visited_chars"]:
			all_visited_chars[load(character["char"])] = true
	return

func serialize_attractions():
	var data = []
	for attraction in attractions:
		if attraction:
			data.append(attraction.data.resource_path)
		else:
			data.append(null)
	return data

func serialize_characters():
	var data = []
	for attraction in attractions:
		if attraction:
			for slot in attraction.slot_nodes:
				if slot.character:
					data.append({
						"char": slot.character.data.resource_path,
						"arrival": slot.character.arrival_time,
						"departure": slot.character.departure_time,
						"slot_index": slot.get_index(),
						"attraction_index": attraction.get_index()
					})
	return data

func serialize_gifts():
	var data = []
	for gift in unclaimed_gifts:
		data.append(({
			"char": unclaimed_gifts[gift][0].resource_path,
			"amount": unclaimed_gifts[gift][1]
		}))
	return data

func serialize_purchased_attractions():
	var data = []
	for purchased_attraction in purchased_attractions:
		data.append({
			"attraction": purchased_attraction.resource_path
		})
	return data

func serialize_all_visited_chars():
	var data = []
	for character in all_visited_chars:
		data.append({
			"char": character.resource_path
		})
	return data
