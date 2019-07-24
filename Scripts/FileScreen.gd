extends FileDialog


func _ready():
	set_filters(["*.its ; Initiative Tracker Saves"]) # only show "*.its" files
	popup()

func _set_save_mode():
	set_mode(FileDialog.MODE_SAVE_FILE) # checks if file exists before
	set_access(FileDialog.ACCESS_FILESYSTEM) # select file and directory

func _set_load_mode():
	set_mode(FileDialog.MODE_OPEN_FILE) # select only 1 file
	set_access(FileDialog.ACCESS_FILESYSTEM) # select file and directory
