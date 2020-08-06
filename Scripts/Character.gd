extends HBoxContainer

onready var expression = Expression.new()

func _ready():
# warning-ignore:return_value_discarded
	$Init.connect("focus_exited", self, "_check_input", [null, $Init])
# warning-ignore:return_value_discarded
	$HP.connect("focus_exited", self, "_check_input", [null, $HP])
# warning-ignore:return_value_discarded
	$AC.connect("focus_exited", self, "_check_input", [null, $AC])
	
# warning-ignore:return_value_discarded
	$Init.connect("text_entered", self, "_check_input", [$Init]) # enter is pressed
# warning-ignore:return_value_discarded
	$HP.connect("text_entered", self, "_check_input", [$HP])
# warning-ignore:return_value_discarded
	$AC.connect("text_entered", self, "_check_input", [$AC])

# warning-ignore:return_value_discarded
	$Init.connect("focus_exited", self, "_clear_select", [$Init])
# warning-ignore:return_value_discarded
	$Name.connect("focus_exited", self, "_clear_select", [$Name])
# warning-ignore:return_value_discarded
	$HP.connect("focus_exited", self, "_clear_select", [$HP])
# warning-ignore:return_value_discarded
	$AC.connect("focus_exited", self, "_clear_select", [$AC])
# warning-ignore:return_value_discarded
	$Info.connect("focus_exited", self, "_clear_select", [$Info])


# @name: _clear_select
# @desc: clears selected text when focus is lost
# @param: node - the node who's text is to be cleared
func _clear_select(node):
	node.select(0,0)


# @name: _delete_button
# @desc: delete button pushed, remove ROW from the scene
func _delete_button():
	get_parent().get_parent().queue_free()


# @name: _check_input
# @desc: if input is expression, calculate. If error, make red
func _check_input(text, node):
	var result
	if text == null:
		result = _eval(node.text)
	else:
		result = _eval(text)

	if result != null:
		node.text = result
		node.add_color_override("font_color", Color(1, 1, 1, 0.8)) # white
	else:
		node.add_color_override("font_color", Color(1, 0.27, 0, 1)) # red


# @name: _eval
# @desc: evaluates expression
# @param: command: string to be evaluated
# @return: null if error, result otherwise
func _eval(command):
	var error = expression.parse(command, [])
	if error != OK:
		print(expression.get_error_text())
		return null
	var result = expression.execute([], null, true) # need to check if failed
	if not expression.has_execute_failed():
		return str(result)
	return null
