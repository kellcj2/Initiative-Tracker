extends HBoxContainer

func _ready():
	var delButton = get_node("Button")
	delButton.connect("button_down", self, "_delete_button")
	
	var init_text = get_node("Init")
	init_text.connect("focus_exited", self, "_check_input")


# @name: _delete_button
# @desc: delete button pushed, remove row from the scene
func _delete_button():
	get_parent().queue_free()


# @name: _check_input
# @desc: if input is expression, calculate. If error, make red
func _check_input():
	var init_node = get_node("Init")
	var txt = init_node.text
	var numbers = []
	var ops = ''
	var i = 0
	var max_len = len(txt)

	while i < max_len:
		var num = ''
		if txt[i] == '-': # deals with negatives
			num += txt[i]
			if i+1 < max_len:
				 i += 1

		while int(txt[i]): # get entire integer
			num += txt[i]
			if i < len(txt)-1: 
				i += 1
			else: # end of input
				break

		if len(num) > 0 or txt[i] == '0':
			numbers.append(int(num))
		if (txt[i] == '+' or txt[i] == '-') and (numbers.size() > 0):
			ops += txt[i]
		elif (txt[i] != ' ') and (txt[i] != '0') and (!int(txt[i])): # invalid character, error
			init_node.add_color_override("font_color", Color(1, 0.27, 0, 1))
			return
		i += 1
	# -- end while
	#print(numbers)
	if ops == '+':
		init_node.text = String(numbers[0] + numbers[1])
	elif ops == '-' and numbers.size() > 1:
		init_node.text = String(numbers[0] - numbers[1])
	init_node.add_color_override("font_color", Color(1, 1, 1, 0.8))