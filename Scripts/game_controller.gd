extends Node

# What does this do again?
# It spawns the characters, handles the money, and places
# the attractions in the scene

var money: int = 0
var drink: DrinkData = null
var num_attraction_slots = 4
var attractions: Array[AttractionData] = []

@onready var attractions_container = $"../EntitiesContainer/Attractions"
@onready var characters_container = $"../EntitiesContainer/Characters"
var gametick

func _ready():
	drink = load("res://Resources/drinks/first_drink.tres")
	var attraction = load("res://Resources/attractions/dart_board.tres")
	for i in range(num_attraction_slots):
		attractions.append(attraction)

var time_accumulator: float = 0.0
var tick_interval: float = 2.0  # Seconds between ticks

func _process(delta):
	time_accumulator += delta
	
	if time_accumulator >= tick_interval:
		time_accumulator -= tick_interval
		game_tick()

func game_tick():
	if drink != null and drink.num_uses > 0:
		var possible_chars = find_intersection(Dictionary(drink.possible_chars), {})
	
func find_intersection(set_a: Dictionary, set_b: Dictionary):
	var res = {}
	for item in set_a:
		if item in set_b:
			res[item] = {}
	return res
