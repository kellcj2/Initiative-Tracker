extends MarginContainer

class CustomSorter:
	# @name: sort
	# @param: 2 Character nodes to be compared
	# @desc: compares the Init value of the nodes
	# @return: boolean, T if first > second
	static func sort_val(a, b):
		var first = a.get_node("Character/Init").text
		var second = b.get_node("Character/Init").text

		if int(first) and int(second):
			if int(first) > int(second):
				return true

		if first == '0' and second == '0':
			return false
		if first == '0' and int(second):
			return 0 > int(second)
		if second == '0' and int(first):
			return int(first) > 0

		return false

	# sorts by orderNum instead of Init value
	static func sort_order(a, b):
		var first = a.orderNum
		var second = b.orderNum
		if first < second:
			return true
		else:
			return false


var newRow = preload("res://Scenes/Row.tscn")
var newFileScreen = preload("res://Scenes/FileScreen.tscn")
var numRows = 0

# @name: ready
# @desc: connects buttons to their functions
func _ready():
	#var newRow = preload("res://Character.tscn")
	var insertButton = get_node("VBoxContainer/Buttons/Insert")
	insertButton.connect("button_down", self, "_new_character")
	
	var sortButton = get_node("VBoxContainer/Buttons/Sort")
	sortButton.connect("button_down", self, "_sort_characters", ["sort_val"])
	
	var saveButton = get_node("VBoxContainer/Buttons/SaveGame")
	saveButton.connect("button_down", self, "_save_screen")
	
	var loadButton = get_node("VBoxContainer/Buttons/LoadGame")
	loadButton.connect("button_down", self, "_load_screen")
	
	var clearButton = get_node("VBoxContainer/Buttons/Clear")
	clearButton.connect("button_down", self, "_clear_rows")
	
	_new_character() # make first blank character row


# @name:  _clear_rows
# @desc:  brings up a window asking to confirm clearing all rows
func _clear_rows():
	var confirm = ConfirmationDialog.new()
	get_node("VBoxContainer").add_child(confirm)
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
	_new_character()


# @name: _new_character
# @param: addRow - object to be instanced
# @desc: instances object and adds to the current scene
func _new_character():
	var row = newRow.instance()
	numRows += 1
	
	get_node("VBoxContainer").add_child(row)
	row.orderNum = numRows
	row.get_node("Buttons/ButtonUp").connect("button_down", self, "_move_up", [row])
	row.get_node("Buttons/ButtonDown").connect("button_down", self, "_move_down", [row])
	row.connect("tree_exiting", self, "_row_deleted")

# @name: _move_up
# @param: row - Row to be moved up
# @desc: swaps the order of 2 rows in the scene
func _move_up(row):
	if row.orderNum == 1: # already at top
		return

	var nodes = get_tree().get_nodes_in_group("Rows")
	var rowAbove = 0
	for i in nodes: # find row immediately above it
		if i.orderNum == (row.orderNum - 1):
			rowAbove = i
			break
	
	if typeof(rowAbove) != TYPE_INT:
		rowAbove.orderNum += 1
		row.orderNum -= 1
		_sort_characters("sort_order") # sort by orderNum


# @name: _move_down
# @param: row - Row to be moved down
# @desc: swaps the order of 2 rows in the scene
func _move_down(row):
	if row.orderNum == numRows: # already at bottom
		return
	var rowBelow = 0
	var nodes = get_tree().get_nodes_in_group("Rows")
	
	for i in nodes: # find row immediately below it
		if i.orderNum == (row.orderNum + 1):
			rowBelow = i
			break
	
	if typeof(rowBelow) != TYPE_INT:
		rowBelow.orderNum -= 1
		row.orderNum += 1
		_sort_characters("sort_order") # sort by orderNum


# @name: _row_deleted
# @desc: Keeps track of number of rows, called when a row exits the scene
func _row_deleted():
	numRows -= 1
	if get_tree():
		var nodes = get_tree().get_nodes_in_group("Rows")
		if nodes:
			_set_order_numbers(nodes)


# @name: _sort_characters
# @param: type of sort - either "sort_order" or "sort_val"
# @desc: sorts the rows in the scene
func _sort_characters(sort_type):
	var sortArray = get_tree().get_nodes_in_group("Rows")
	sortArray.sort_custom(CustomSorter, sort_type)
	
	var newNodes = _make_new_rows(sortArray)
	_test_integers(newNodes) # checks if Init is integer
	
	var temp = numRows
	var oldRows = get_tree().get_nodes_in_group("Rows")
	for i in oldRows: # remove current nodes from scene
		i.queue_free()
	numRows = temp
	
	var parent = get_node("VBoxContainer")
	for i in newNodes: # add sorted nodes to scene
		parent.add_child(i)


# @name: _test_integers
# @param: array of row nodes in the scene
# @desc: goes through all row nodes and checks if the Init valus is an integer
func _test_integers(rows):
	for i in rows:
		if not int(i.get_node("Character/Init").text) and i.get_node("Character/Init").text != '0': # Init is not an integer
			i.get_node("Character/Init").add_color_override("font_color", Color(1, 0.27, 0, 1))
			i.get_node("Character/Init").text = '0'


# @name: _make_new_rows
# @param: old - array of nodes to be copied
# @desc: creates new nodes and copies the data from the old, connecting new signals as well
# @return: array of row nodes with identical data to old
func _make_new_rows(old):
	var new_rows = []
	for i in old:
		# TODO: might be easier to just add everything to a big dictionary
		var row = newRow.instance()
		row.get_node("Character/Init").text = i.get_node("Character/Init").text
		row.get_node("Character/Name").text = i.get_node("Character/Name").text
		row.get_node("Character/Info").text = i.get_node("Character/Info").text
		row.get_node("Buttons/ButtonUp").connect("button_down", self, "_move_up", [row])
		row.get_node("Buttons/ButtonDown").connect("button_down", self, "_move_down", [row])
		row.connect("tree_exiting", self, "_row_deleted")
		new_rows.append(row)
	
	_set_order_numbers(new_rows)
	return new_rows


# @name: _set_order_numbers
# @param: rows - array of rows to be set
# @desc: goes through 'rows' and sets their 'orderNum' to be in the array's order
func _set_order_numbers(rows):
	var num = 1
	for i in rows:
		i.orderNum = num
		num += 1


# @name: _save_screen
# @desc: opens up the save screen
func _save_screen():
	var save = newFileScreen.instance()
	save._set_save_mode()
	get_node("VBoxContainer").add_child(save)
	save.connect("file_selected", self, "_save_file")


# @name:  _load_screen
# @desc:  brings up a file browser to select a save file to load
func _load_screen():
	var loadScreen = newFileScreen.instance()
	loadScreen._set_load_mode()
	get_node("VBoxContainer").add_child(loadScreen)
	loadScreen.connect("file_selected", self, "_load_file")


# @name:  _save_file
# @param: filename - the file to save to
# @desc:  saves the current rows into a file
func _save_file(var filename):
	var accept = AcceptDialog.new()
	accept.rect_min_size = Vector2(400, 0)
	accept.window_title = "Save File"
	get_node("VBoxContainer").add_child(accept)
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
	while not load_game.eof_reached():
		var current_line = parse_json(load_game.get_line())
		if current_line == null: # there's a blank line at end of file when saving for whatever reason...
			break
		
		var new_object = load(current_line["filename"]).instance()
		get_node(current_line["parent"]).add_child(new_object)
		for i in current_line.keys(): # sets appropriate data for the new object
			if i == "filename" or i == "parent":
				continue
			var data_path = "Character/" + i
			new_object.get_node(data_path).text = current_line[i]
	load_game.close()





