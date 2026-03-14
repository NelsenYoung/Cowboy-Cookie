extends Resource
class_name CharacterData

@export var id: int
@export var char_name: String
@export var poses: Array[Texture2D]
@export var hit_rate: float
@export var leave_rate: float
@export var money_rate: float
@export var description: String

func choose_pose(idx: int):
	pass

func leave_money():
	pass
