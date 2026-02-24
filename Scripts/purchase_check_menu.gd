extends Control
class_name AttractionPurchaseCheckMenu

@onready var money_label = $ColorRect2/MoneyBox/Money

func setup(money: int):
	print(money_label)
	money_label.text = str(money)
