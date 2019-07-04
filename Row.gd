extends HBoxContainer


var orderNum

func _ready():
	orderNum = -1



func _get_save_data():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"Init" : get_node("Character/Init").text,
		"Name" : get_node("Character/Name").text,
		"Info" : get_node("Character/Info").text
	}
	return save_dict