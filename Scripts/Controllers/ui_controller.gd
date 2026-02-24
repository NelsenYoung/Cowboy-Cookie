extends CanvasLayer

@onready var game_controller = $"../GameController"

@onready var slot_buttons_container = $AttractionSlotButtons
@onready var slot_buttons = slot_buttons_container.get_children()

@onready var attractions_menu = $AttractionMenu
@onready var attraction_grid = $AttractionMenu/MarginContainer/ScrollContainer/AttractionGrid
@onready var attraction_menu_close_button = $AttractionMenu/CloseButton
@onready var purchased_attractions = game_controller.purchased_attractions

@onready var drinks_menu = $DrinkMenu
@onready var drink_grid = $DrinkMenu/MarginContainer/ScrollContainer/AttractionGrid
@onready var drink_menu_close_button = $DrinkMenu/CloseButton

@onready var gifts_menu_button = $TextureButton
@onready var gifts_menu = $GiftsMenu
@onready var gifts_vbox = $GiftsMenu/MarginContainer/ScrollContainer/VBoxContainer

@onready var money_label = $MoneyDisplay/MoneyLabel

signal attraction_card_selected(slot_idx: int, attraction: AttractionData)
signal attraction_purchase_requested(slot_indx: int, attraction: AttractionData)
signal drink_card_selected(drink: DrinkData)
signal gift_claimed(idx: int, amount: int)

var attraction_card = preload("res://Scenes/attraction_card.tscn")
var drink_card = preload("res://Scenes/drink_card.tscn")
var gift_card = preload("res://Scenes/gift_card.tscn")
var purchase_check_menu = preload("res://Scenes/purchase_check_menu.tscn")
var slot_idx = null

func _ready():
	var drink_slot = $DrinkSlotButton/SlotButton1
	drink_slot.pressed.connect(_on_drink_slot_pressed)
	gifts_menu_button.pressed.connect(_on_gifts_menu_button_pressed)
	
	var close_gifts_menu_button = $GiftsMenu/CloseButton
	close_gifts_menu_button.pressed.connect(_on_close_gifts_menu_button_pressed)
	
	attraction_menu_close_button.pressed.connect(close_attraction_menu)
	drink_menu_close_button.pressed.connect(close_drink_menu)
	for i in range(slot_buttons.size()):
		# We use the bind function here to pass extra data on a signal that does not normally have it
		# The button.pressed signal does not emit an index normally but in this case we need it, so we use bind
		slot_buttons[i].pressed.connect(_on_slot_button_pressed.bind(i))

func _on_gifts_menu_button_pressed() -> void:
	gifts_menu.visible = true
	
	var gifts = game_controller.unclaimed_gifts
	for key in gifts:
		var char = gifts[key][0]
		var amount = gifts[key][1]
		var card = gift_card.instantiate()
		card.setup(char, amount)
		gifts_vbox.add_child(card)
		var child_button = card.get_child(2)
		child_button.pressed.connect(_on_gift_claimed.bind(card, key, amount))

func _on_gift_claimed(card: GiftCard, key: int, amount: int):
	gift_claimed.emit(key, amount)
	card.queue_free()

func _on_close_gifts_menu_button_pressed():
	gifts_menu.visible = false
	for child in gifts_vbox.get_children():
		child.queue_free()

func update_money_label(updated_value: int):
	money_label.text = "$%d" % updated_value

func _on_drink_slot_pressed() -> void:
	var drinks = load_drinks_from_dir()
	populate_drink_menu(drinks)
	drinks_menu.visible = true
	return

func load_drinks_from_dir() -> Array[DrinkData]:
	var drinks: Array[DrinkData] = []
	var dir_name = "res://Resources/drinks/"
	var dir = DirAccess.open(dir_name)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var drink = load(dir_name + file_name)
			drinks.append(drink)
		file_name = dir.get_next()
	dir.list_dir_end()
	return drinks

func populate_drink_menu(drink_data: Array[DrinkData]) -> void:
	for drink in drink_data:
		var card = drink_card.instantiate()
		card.setup(drink)
		drink_grid.add_child(card)
		card.get_child(4).pressed.connect(_on_drink_purchase_request.bind(drink))
	return

func _on_drink_purchase_request(drink: DrinkData):
	var check_menu = purchase_check_menu.instantiate()
	drinks_menu.add_child(check_menu)
	check_menu.setup(drink.price)
	
	if game_controller.money >= drink.price:
		check_menu.get_child(1).get_child(2).get_child(0).pressed.connect(_on_drink_card_selected.bind(drink, check_menu))
	else:
		check_menu.get_child(1).get_child(2).get_child(0).text = "Not Enough"
	check_menu.get_child(1).get_child(2).get_child(1).pressed.connect(_on_purchase_declined.bind(check_menu))

func _on_drink_card_selected(drink: DrinkData, check_menu):
	check_menu.queue_free()
	drink_card_selected.emit(drink)
	close_drink_menu()

func close_drink_menu():
	drinks_menu.visible = false
	slot_idx = null
	for child in drink_grid.get_children():
		child.queue_free()

func _on_slot_button_pressed(slot_index: int):
	slot_idx = slot_index
	var attractions = load_attractions_from_dir()
	populate_attraction_menu(attractions)
	attractions_menu.visible = true
	# print("Slot ", slot_idx, " Pressed!")
	
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
	if slot_idx == null:
		push_error("Slot index is null!")
		attractions_menu.visible = false
		return
	
	for attraction in attraction_data:	
		var card = attraction_card.instantiate()
		card.setup(attraction)
		attraction_grid.add_child(card)
		if attraction not in purchased_attractions:
			card.get_child(4).color = Color(0, 0, 0, 0.5)
			card.get_child(5).pressed.connect(_on_locked_attraction_selected.bind(slot_idx, attraction))
		else:
			card.get_child(5).pressed.connect(_on_attraction_card_selected.bind(slot_idx, attraction))
	return

func _on_attraction_card_selected(slot_index: int, attraction: AttractionData):
	attraction_card_selected.emit(slot_index, attraction)
	close_attraction_menu()

func _on_locked_attraction_selected(slot_idx: int, attraction: AttractionData):
	var check_menu = purchase_check_menu.instantiate()
	attractions_menu.add_child(check_menu)
	check_menu.setup(attraction.price)
	if game_controller.money >= attraction.price:
		check_menu.get_child(1).get_child(2).get_child(0).pressed.connect(_on_purchase_requested.bind(slot_idx, attraction, check_menu))
	else:
		check_menu.get_child(1).get_child(2).get_child(0).text = "Not Enough"
	check_menu.get_child(1).get_child(2).get_child(1).pressed.connect(_on_purchase_declined.bind(check_menu))

func _on_purchase_requested(slot_idx: int, attraction: AttractionData, check_menu):
	check_menu.queue_free()
	attraction_purchase_requested.emit(slot_idx, attraction)
	close_attraction_menu()

func _on_purchase_declined(check_menu):
	check_menu.queue_free()

func close_attraction_menu():
	attractions_menu.visible = false
	slot_idx = null
	for child in attraction_grid.get_children():
		child.queue_free()
