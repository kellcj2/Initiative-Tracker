extends VBoxContainer

var orderNum

func _ready():
	orderNum = get_parent().get_parent().numRows
	
	var delButton = get_node("Char/Delete")
	delButton.connect("button_down", self, "_delete_button")


func _delete_button():
	queue_free()


func _get_save_data():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"Init" : get_node("Char/Character/Init").text,
		"Name" : get_node("Char/Character/Name").text,
		"HP" : get_node("Char/Character/HP").text,
		"AC" : get_node("Char/Character/AC").text,
		"Info" : get_node("Char/Character/Info").text
	}
	return save_dict
