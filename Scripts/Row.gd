extends VBoxContainer

var orderNum

func _ready():
	get_node("Labels").hide()
	orderNum = get_parent().get_parent().numRows
	
	var delButton = get_node("Char/Delete")
	delButton.connect("button_down", self, "_delete_button")

	var menu = get_parent().get_node("Menu")
	if !menu.nameVisible:
		get_node("Char/Character/Name").hide()
	if !menu.hpVisible:
		get_node("Char/Character/HP").hide()
	if !menu.acVisible:
		get_node("Char/Character/AC").hide()
	if !menu.infoVisible:
		get_node("Char/Character/Info").hide()

func _delete_button():
	if orderNum == 1: # hack
		var rows = get_tree().get_nodes_in_group("Rows")
		for row in rows:
			if row.orderNum == 2 or row.orderNum == 1:
				row.get_node("Labels").show()
		
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