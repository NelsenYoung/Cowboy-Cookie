extends CanvasLayer

@onready var HUD = $HUD
@onready var slot_buttons_container = $AttractionSlotButtons
@onready var attractions_menu = $AttractionMenu
@onready var attraction_grid = $AttractionMenu/MarginContainer/ScrollContainer/AttractionGrid
@onready var slot_buttons = slot_buttons_container.get_children()

signal attraction_slot_clicked(slot_index: int)

var attraction_card = preload("res://Scenes/attraction_card.tscn")

func _ready():
	for i in range(slot_buttons.size()):
		# We use the bind function here to pass extra data on a signal that does not normally have it
		# The button.pressed signal does not emit an index normally but in this case we need it, so we use bind
		slot_buttons[i].pressed.connect(_on_slot_button_pressed.bind(i))

func _on_slot_button_pressed(slot_index: int):
	#attraction_slot_clicked.emit(slot_index)
	var attractions = load_attractions_from_dir()
	populate_attraction_menu(attractions)
	attractions_menu.visible = true
	print("Slot ", slot_index, " Pressed!")
	
func load_attractions_from_dir() -> Array[AttractionData]:
	var attractions: Array[AttractionData] = []
	var dir_name = "res://Resources/attractions/"
	var dir = DirAccess.open(dir_name)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var attraction = load(dir_name + file_name)
			attractions.append(attraction)
		file_name = dir.get_next()
	dir.list_dir_end()
	return attractions
	
func populate_attraction_menu(attraction_data: Array[AttractionData]) -> void:
	for attraction in attraction_data:
		var card = attraction_card.instantiate()
		card.setup(attraction)
		attraction_grid.add_child(card)
	return
