extends MarginContainer

signal attraction_chosen(tex: Texture2D)
var attractions: Array[AttractionData] = []

@export var attraction_node: PackedScene
@onready var container = $MarginContainer

func _ready():
	load_attraction_data()
	populate_menu()
	connect_attraction_signals()

func load_attraction_data():
	var dir = DirAccess.open("res://Resources/attractions/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var item = load("res://Resources/attractions/" + file_name) as AttractionData
				attractions.append(item)
			file_name = dir.get_next()

func populate_menu():
	for item in attractions:
		print(item.icon)
		var cur_attraction = attraction_node.instantiate()
		container.add_child(cur_attraction)
		cur_attraction.set_data(item)
		

func connect_attraction_signals():
	var attractions = get_child(1).get_children()
	for item in attractions:
		item.attraction_selected.connect(set_attraction)

func set_attraction(tex: Texture2D):
	attraction_chosen.emit(tex)
	print("Menu: ", tex)
