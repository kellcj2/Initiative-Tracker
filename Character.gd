extends MarginContainer

func _ready():
	var button = get_node("Character/Button")
	button.connect("button_down", self, "_delete_button")


func _delete_button():
	self.queue_free()