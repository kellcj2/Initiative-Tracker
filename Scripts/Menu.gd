extends HBoxContainer


var file
var options
var newFileScreen = preload("res://Scenes/FileScreen.tscn")
export (int) var nameVisible
export (int) var hpVisible
export (int) var acVisible
export (int) var infoVisible

func _ready():
	nameVisible = true
	hpVisible = true
	acVisible = true
	infoVisible = true
	
	file = get_node("File").get_popup()
	file.add_item("Clear")
	file.add_item("Save")
	file.add_item("Load")
	file.add_item("Quit")
		
	options = get_node("Options").get_popup()
	options.add_radio_check_item("Name")
	options.add_radio_check_item("HP")
	options.add_radio_check_item("AC")
	options.add_radio_check_item("Info")
	
	for i in options.get_item_count():
		options.set_item_checked(i, true)
	
	file.connect("id_pressed", self, "_file_pressed")
	options.connect("id_pressed", self, "_options_pressed")


# @name: _file_pressed
# @desc: when an option on the file menu is pressed
func _file_pressed(ID):
	if ID == 0:
		_clear_rows()
	elif ID == 1:
		_save_screen()
	elif ID == 2:
		_load_screen()
	elif ID == 3:
		var confirm = ConfirmationDialog.new()
		add_child(confirm)
		confirm.window_title = "Quit"
		confirm.dialog_text = "Are you sure you want to quit?"
		confirm.popup_centered()
		confirm.connect("confirmed", self, "_quit_screen")


# @name: _quit_screen
# @desc: end the program
func _quit_screen():
	get_tree().quit()


# @name:  _clear_rows
# @desc:  brings up a window asking to confirm clearing all rows
func _clear_rows():
	var confirm = ConfirmationDialog.new()
	add_child(confirm)
	confirm.window_title = "Clear"
	confirm.dialog_text = "Clear All Rows?"
	confirm.popup_centered()
	confirm.connect("confirmed", self, "_confirm_clear")


# @name:  _confirm_clear
# @desc:  when "ok" is pressed on the clear rows dialog, clear all rows
func _confirm_clear():
	var rows = get_tree().get_nodes_in_group("Rows")
	for i in rows:
		i.queue_free()


# @name: _save_screen
# @desc: opens up the save screen
func _save_screen():
	var save = newFileScreen.instance()
	save._set_save_mode()
	add_child(save)
	save.connect("file_selected", self, "_save_file")


# @name:  _load_screen
# @desc:  brings up a file browser to select a save file to load
func _load_screen():
	var loadScreen = newFileScreen.instance()
	loadScreen._set_load_mode()
	add_child(loadScreen)
	loadScreen.connect("file_selected", self, "_load_file")


# @name:  _save_file
# @param: filename - the file to save to
# @desc:  saves the current rows into a file
func _save_file(var filename):
	var accept = AcceptDialog.new()
	accept.rect_min_size = Vector2(400, 0)
	accept.window_title = "Save File"
	add_child(accept)
	if filename[filename.length()-5] == "/":
		accept.dialog_text = "Error: No File Selected"
		accept.popup_centered()
		return
	else: 
		accept.dialog_text = "File Saved as " + filename
		accept.popup_centered()

	var save_game = File.new()
	if save_game.open(filename, File.WRITE) != 0:
		return # can't open file
	var save_nodes = get_tree().get_nodes_in_group("Rows")
	for i in save_nodes: # get all data in current rows and write to file
		var char_data = i._get_save_data()
		save_game.store_line(to_json(char_data))
	save_game.close()
	
	print("Done saving")
	print(filename)


# @name: _load_file
# @param: none
# @desc: removes all Rows and loads new ones from the save file
func _load_file(var filename):
	var load_game = File.new()
	if not load_game.file_exists(filename):
		print("No file found")
		return # no save to load

	# delete current scene
	var save_nodes = get_tree().get_nodes_in_group("Rows")
	for i in save_nodes:
		i.queue_free()
	
	# process saved data
	load_game.open(filename, File.READ)
	var numRows = 0
	while not load_game.eof_reached():
		var current_line = parse_json(load_game.get_line())
		if current_line == null: # there's a blank line at end of file when saving for whatever reason...
			break
		
		numRows += 1
		var new_object = load(current_line["filename"]).instance()
		get_node(current_line["parent"]).add_child(new_object)
		new_object.orderNum = numRows
		if numRows == 1:
			new_object.get_node("Labels").show()
		
		for i in current_line.keys(): # sets appropriate data for the new object
			if i == "filename" or i == "parent":
				continue
			var data_path = "Char/Character/" + i
			new_object.get_node(data_path).text = current_line[i]

	load_game.close()


# @name: _options_pressed
# @desc: when an option on the options menu is pressed
func _options_pressed(ID):
	options.set_item_checked(ID, !options.is_item_checked(ID))
	var current
	if ID == 0:
		nameVisible = !nameVisible
		current = nameVisible
	elif ID == 1:
		hpVisible = !hpVisible
		current = hpVisible
	elif ID == 2:
		acVisible = !acVisible
		current = acVisible
	elif ID == 3:
		infoVisible = !infoVisible
		current = infoVisible
	
	var name = options.get_item_text(ID)
	
	var rows = get_tree().get_nodes_in_group("Rows")
	for row in rows:
		if current:
			row.get_node("Char/Character/" + name).show()
			row.get_node("Labels/" + name).show()
		else:
			row.get_node("Char/Character/" + name).hide()
			row.get_node("Labels/" + name).hide()









