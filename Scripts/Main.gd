extends MarginContainer

class CustomSorter:
	# @name: sort
	# @param: 2 Character nodes to be compared
	# @desc: compares the Init value of the nodes
	# @return: boolean, T if first > second
	static func sort_val(a, b):
		var first = a.get_node("Char/Character/Init").text
		var second = b.get_node("Char/Character/Init").text

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
export (int) var numRows = 0

# @name: ready
# @desc: connects buttons to their functions
func _ready():
	#var newRow = preload("res://Character.tscn")
	var insertButton = get_node("VBoxContainer/Buttons/Insert")
	insertButton.connect("button_down", self, "_new_character")
	
	var sortButton = get_node("VBoxContainer/Buttons/Sort")
	sortButton.connect("button_down", self, "_sort_characters", ["sort_val"])
	
	#var saveButton = get_node("VBoxContainer/Buttons/SaveGame")
	#saveButton.connect("button_down", self, "_save_screen")
	
	#var loadButton = get_node("VBoxContainer/Buttons/LoadGame")
	#loadButton.connect("button_down", self, "_load_screen")
	
	#var clearButton = get_node("VBoxContainer/Buttons/Clear")
	#clearButton.connect("button_down", self, "_clear_rows")
	
	#var 
	
	_new_character() # make first blank character row




# @name: _new_character
# @param: addRow - object to be instanced
# @desc: instances object and adds to the current scene
func _new_character():
	var row = newRow.instance()
	numRows += 1

	get_node("VBoxContainer").add_child(row)
	row.orderNum = numRows
	row.get_node("Char/Buttons/ButtonUp").connect("button_down", self, "_move_up", [row])
	row.get_node("Char/Buttons/ButtonDown").connect("button_down", self, "_move_down", [row])
	row.connect("tree_exiting", self, "_row_deleted")

	if numRows == 1:
		row.get_node("Labels").show()


# @name: _move_up
# @param: row - Row to be moved up
# @desc: swaps the order of 2 rows in the scene
func _move_up(row):
	if row.orderNum == 1: # already at top
		return

	var rowAbove = row.orderNum - 1
	var rows = get_tree().get_nodes_in_group("Rows")
	for i in rows:
		if i.orderNum == rowAbove:
			i.orderNum += 1
			break
	
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
	_set_order_numbers()
	if numRows > 0:
		var nodes = get_tree().get_nodes_in_group("Rows")
		for n in nodes:
			print("ordernum: " + String(n.orderNum))
			if n.orderNum == 1:
				n.get_node("Labels").show()
	
	print("num rows: " + String(numRows))

# @name: _sort_characters
# @param: type of sort - either "sort_order" or "sort_val"
# @desc: sorts the rows in the scene
func _sort_characters(sort_type):
	var sortArray = get_tree().get_nodes_in_group("Rows")
	sortArray.sort_custom(CustomSorter, sort_type)
	var newNodes = _make_new_rows(sortArray)

	var oldRows = get_tree().get_nodes_in_group("Rows")
	for i in oldRows: # remove current nodes from scene
		i.queue_free()

	var parent = get_node("VBoxContainer")
	for i in newNodes: # add sorted nodes to scene
		parent.add_child(i)
		numRows += 1
		if numRows == 1:
			i.get_node("Labels").show()
	
	_test_integers(newNodes) # checks if Init is integer


# @name: _test_integers
# @param: array of row nodes in the scene
# @desc: goes through all row nodes and checks if the Init valus is an integer
func _test_integers(rows):
	for i in rows:
		var text = i.get_node("Char/Character/Init").text
		for j in text:
			if not int(j) and j != '0':
				i.get_node("Char/Character/Init").add_color_override("font_color", Color(1, 0.27, 0, 1))
				i.get_node("Char/Character/Init").placeholder_text = '0'
				break


# @name: _make_new_rows
# @param: old - array of nodes to be copied
# @desc: creates new nodes and copies the data from the old, connecting new signals as well
# @return: array of row nodes with identical data to old
func _make_new_rows(old):
	var new_rows = []
	for i in old:
		# TODO: might be easier to just add everything to a big dictionary
		var row = newRow.instance()
		row.get_node("Char/Character/Init").text = i.get_node("Char/Character/Init").text
		row.get_node("Char/Character/Name").text = i.get_node("Char/Character/Name").text
		row.get_node("Char/Character/HP").text = i.get_node("Char/Character/HP").text
		row.get_node("Char/Character/AC").text = i.get_node("Char/Character/AC").text
		row.get_node("Char/Character/Info").text = i.get_node("Char/Character/Info").text
		row.get_node("Char/Buttons/ButtonUp").connect("button_down", self, "_move_up", [row])
		row.get_node("Char/Buttons/ButtonDown").connect("button_down", self, "_move_down", [row])
		row.connect("tree_exiting", self, "_row_deleted")
		new_rows.append(row)
	
	_set_order_numbers()
	return new_rows


# @name: _set_order_numbers
# @desc: goes through rows and sets their 'orderNum' to be in the scene order
func _set_order_numbers():
	var num = 1
	var rows = get_tree().get_nodes_in_group("Rows")
	for i in rows:
		i.orderNum = num
		num += 1

