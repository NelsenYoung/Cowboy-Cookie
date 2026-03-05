extends Panel

func setup(character: CharacterData):
	var icon = $Panel/CharacterPanel/TextureRect
	icon.texture = character.poses[0]
	
	var name = $Panel/Control/NameContainer/Label2
	name.text = character.char_name
