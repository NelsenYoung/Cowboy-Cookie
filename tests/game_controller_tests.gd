extends Node

@onready var GameController = load("res://Scripts/Controllers/game_controller.gd")
@onready var gc = GameController.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run_tests()

func run_tests() -> void:
	print("/ --- Running Tests --- /")
	print("/ --- Simple Tests --- /")
	find_intersection_test()
	choose_rand_from_array_test()
	array_to_dict_test()
	
	print("/ --- Spawning Tests ---/")
	spawn_attraction_test()
	spawn_drink_test()
	spawn_char_test()
	print("/ --- Finished Running Tests --- /")
	
func find_intersection_test() -> void:
	var dd = load("res://Assets/Donut Don.png")
	var esd = load("res://Assets/Evil SnickerDoodle.png")
	var jbj = load("res://Assets/Jawbreaker Joe.png")
	var array = [dd, esd, jbj]
	var dict = {dd: true}
	var res = gc.find_intersection(array, dict)
	assert(res == [dd], "Incorrectly calculated the intersection of the array and the dictionary")
	print("/ --- Passed Intersection Test --- /")

func choose_rand_from_array_test() -> void:
	var dd = load("res://Assets/Donut Don.png")
	var esd = load("res://Assets/Evil SnickerDoodle.png")
	var jbj = load("res://Assets/Jawbreaker Joe.png")
	var array = [dd, esd, jbj]
	var idx = randi_range(0, 0)
	assert(dd == array[idx])
	print("/ --- Passed Rand Array Test --- /")

func array_to_dict_test() -> void:
	pass

func spawn_attraction_test() -> void:
	pass

func spawn_drink_test() -> void:
	pass

func spawn_char_test() -> void:
	pass
