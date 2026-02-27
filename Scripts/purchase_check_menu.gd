extends Control
class_name AttractionPurchaseCheckMenu

@onready var money_label = $Panel/MoneyBox/Money

func setup(money: int):
	print(money_label)
	money_label.text = str(money)
