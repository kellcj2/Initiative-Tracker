extends MarginContainer

class CustomSorter:
	# @name: sort
	# @param: 2 Character nodes to be compared
	# @desc: compares the Init value of the nodes
	# @return: boolean, T if first > second
	static func sort(a, b):
		var first = int(a.get_node("Character/Init").text)
		var second = int(b.get_node("Character/Init").text)
		#print(first)
		#print(second)
		if first > second:
			return true
		return false

# @name: ready
# @desc: connects buttons to their functions
func _ready():
	var newChar = preload("res://Character.tscn")
	var insertButton = get_node("VBoxContainer/Header/Insert")
	insertButton.connect("button_down", self, "_add_character", [newChar])
	
	var sortButton = get_node("VBoxContainer/Header/Sort")
	sortButton.connect("button_down", self, "_sort_characters")


# @name: _add_character
# @param: newChar - object to be instanced
# @desc: instances object and adds to the current scene
func _add_character(var newChar):
	get_node("VBoxContainer").add_child(newChar.instance())


# @name: _sort_characters
# @desc: sorts the Characters
func _sort_characters():
	var sortArray = get_tree().get_nodes_in_group("Characters")
	sortArray.sort_custom(CustomSorter, "sort")
	var newNodes = _make_new_chars(sortArray)
	
	for i in sortArray:
		i.queue_free()
	
	var parent = get_node("VBoxContainer")
	for i in newNodes:
		parent.add_child(i)


# @name: _make_new_chars
# @param: old - array of nodes to be sorted
# @desc: makes copies of the old nodes and creates new objects
# @return: array of new character objects
func _make_new_chars(var old):
	var newChar = preload("res://Character.tscn")
	var new_chars = []
	for i in old:
		var character = newChar.instance()
		character.get_node("Character/Init").text = i.get_node("Character/Init").text
		character.get_node("Character/Name").text = i.get_node("Character/Name").text
		character.get_node("Character/Info").text = i.get_node("Character/Info").text
		new_chars.append(character)
	return new_chars